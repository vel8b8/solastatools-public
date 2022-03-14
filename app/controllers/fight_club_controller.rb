class FightClubController < ApplicationController
  helper_method :pretty_attacks

  def start
    campaign_upload = CampaignUpload.find_by_uuid(params[:uuid])
    if campaign_upload.blank?
      # TODO combat specific error page
      redirect_to campaign_analysis_show_path(params[:uuid])
      return
    end
    persistence = Campaign::Persistence.new
    persistence.delete_combat_stats(campaign_upload.uuid)
    FightClubWorker.perform_async(campaign_upload.id)
    redirect_to fight_club_processing_path(campaign_upload.uuid)
  end

  def show
    load_combat_stats
  end

  def show_details
    @fight_club_id = params[:fight_club_id]
    if @fight_club_id
      load_combat_stats
      @club_display_details = {}
      stats_from_run = find_fight_club_stats_from_run(@combat_stats, @fight_club_id)
      if stats_from_run.present?
        @club_display_details[:location_name] = stats_from_run[:location_name] || ''
        @club_display_details[:encounter_index] = stats_from_run[:encounter_index] || ''
        @club_display_details[:monster_names] = stats_from_run[:stats][:monster_party].map {|m| m.name }.join(', ')
        @club_display_details[:combat_instance_table] = []
        @club_display_details[:estimated_difficulty] = stats_from_run[:stats][:player_level]
        @club_display_details[:xp_adjustment] = stats_from_run[:stats][:xp_adjustment]
        if stats_from_run[:stats][:monster_party].size == 1
          # only show for solo encounters not for groups
          @club_display_details[:attacks_summary] = pretty_attacks(stats_from_run[:stats][:monster_party][0].attacks)
        end
        stats_from_run[:stats][:stats_list].each do |combat_stats|
          row_data = {}
          row_data[:player_level] = combat_stats[:player_level]
          row_data[:party_depletion] = combat_stats[:health_remaining_geo_avg_return].present? ? (((1.0 - combat_stats[:health_remaining_geo_avg_return])*100).round(0)).to_i : 100
          row_data[:party_depletion] = 100 if combat_stats[:average_character_deaths] >= 4
          row_data[:tpk] = combat_stats[:average_character_deaths] >= 4 ? 'TPK' : ''
          row_data[:win_rate] = (combat_stats[:win_rate]*100&.round(0))&.to_i
          row_data[:average_character_deaths] = combat_stats[:average_character_deaths]&.round(1)
          @club_display_details[:combat_instance_table] << row_data
        end
        
      end
    end
  end

  def status
    load_combat_stats
    render json: {ready: @combat_stats, uuid: @upload_uuid}
  end

  def processing
    @upload_uuid = params[:uuid]
  end

  # attacks: Sim::MonsterDefinition attacks hash
  def pretty_attacks(attacks)
    output = ""
    # 	{:melee=>["1 x 1D5+1, to_hit + 2", "1 x 1D3+1, to_hit + 2"], :ranged=>["1 x 1D6+1, to_hit + 3"], :magic_ranged=>[]}
    attacks.each_pair do |attack_type, data|
      next unless data.present?
      output << " ; " if output.size > 0
      output << "#{attack_type}: "
      data.each_with_index do |attack_instance, index|
        output << "), " if index > 0
        output << "("
        condensed = attack_instance.gsub(/1 x /, "")
        condensed.gsub!(/(\d) x /, "\\1x")
        condensed.gsub!(/, to_hit \+ /, " AB+")
        output << condensed
      end
      output << ")"
    end
    output
  end

  private

  def load_combat_stats
    persistence = Campaign::Persistence.new
    @upload_uuid = params[:uuid]
    @campaign_upload = CampaignUpload.find_by_uuid(@upload_uuid)
    @combat_stats = persistence.load_combat_stats(@upload_uuid)
    @xp_adjustment_per_map = nil
    prepare_xp_adjustment if @combat_stats
  end
  
  def prepare_xp_adjustment
    persistence = Campaign::Persistence.new
    validation_results = persistence.load_validation(@upload_uuid)
    @xp_adjustment_per_map = @combat_stats[:encounter_stats]&.inject({}) do |location_map, stats|
      location_name = stats[:location_name]
      location_map[location_name] ||= {}
      location_map[location_name][:xp_adjustment] ||= 0
      location_map[location_name][:xp_adjustment] += stats[:stats][:xp_adjustment]
      location_map[location_name][:ed_list] ||= []
      location_map[location_name][:ed_list] << stats[:stats][:player_level]
      location_map
    end
    validation_results.xp_grants.each_pair do |location_name, grants_list|
      if @xp_adjustment_per_map.key?(location_name)
        @xp_adjustment_per_map[location_name][:granted_xp] = grants_list.sum
      end
    end
    @xp_adjustment_per_map.each_pair do |location_name, xp_data|
      next if xp_data[:ed_list].blank?
      xp_data[:ed_simple_average] = (xp_data[:ed_list].sum / xp_data[:ed_list].size.to_f).round(1)
    end
    @xp_adjustment_grand_totals = {
      campaign_xp_adjustment: @xp_adjustment_per_map.values.inject(0) { |sum, xp_data| sum + xp_data[:xp_adjustment] },
      campaign_granted_xp: @xp_adjustment_per_map.values.inject(0) { |sum, xp_data| sum + xp_data[:granted_xp] }
    }
    @xp_adjustment_grand_totals[:additional_xp_needed] = @xp_adjustment_grand_totals[:campaign_xp_adjustment] - @xp_adjustment_grand_totals[:campaign_granted_xp]
  end

  def find_fight_club_stats_from_run(combat_stats, fight_club_id)
    combat_stats.each_pair do |output_stats_type, stats_from_run_list|
      stats_from_run_list.each do |stats_from_run|
        fight_club_results = stats_from_run[:stats]
        if fight_club_results[:fight_club_id] == fight_club_id
          return stats_from_run
        end
      end
    end
    nil
  end
end
