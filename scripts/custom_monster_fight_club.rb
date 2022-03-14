require 'pp'
class CustomMonsterFightClub
  def initialize(all_args=nil)
    @monster_name = nil
    @campaign_upload_uuid = nil
    @print_combat_log_sample = nil
    all_args&.each do |arg|
      case arg
      when /--monster_name=/
        @monster_name = arg.split(/=/)[1]
      when /--campaign_upload_uuid=/
        @campaign_upload_uuid = arg.split(/=/)[1]
      when /--print_combat_log/
        @print_combat_log_sample = true
      end
    end
  end

  def run(campaign_upload_uuid=nil)
    campaign_upload_uuid = CampaignUpload.last.uuid if @campaign_upload_uuid.blank?
    reference_monster_defs = Sim::SolastaBlueprints.solasta_monster_definitions
    custom_monster_parser = CustomMonsterParser.new(reference_monster_defs)
    persistence = Campaign::Persistence.new
    campaign_container = persistence.load_container(campaign_upload_uuid)
    raise StandardError, "Failed to load campaign container. campaign_upload_uuid=#{campaign_upload_uuid}" if campaign_container.blank?
    custom_monster_defs = custom_monster_parser.create_monster_definitions(campaign_container.custom_monsters)
    pp custom_monster_defs
    custom_monster_defs.each do |custom_monster|
      next if @monster_name.present? && custom_monster.name != @monster_name
      monster_party = [custom_monster]
      fight_club = Sim::FightClub.new
      result = fight_club.estimated_difficulty(monster_party)
      pp result[:stats_list].last[:combat_log_sample] if @print_combat_log_sample
      pp result[:stats_list].last.except(:combat_log_sample, :player_party, :monster_party)
      estimated_difficulty = result[:player_status] == :tpk ? ">" : ""
      estimated_difficulty += result[:player_level].to_s
      puts "Estimated Difficulty ED=#{estimated_difficulty} monster_name=#{custom_monster.name} monster_definition=#{custom_monster.monster_reference_definition}"
    end
  end
end

if __FILE__ == $0
  ::Rails.logger = ActiveSupport::Logger.new(STDOUT) if Rails.env == 'development'
  fight_club = CustomMonsterFightClub.new(ARGV)
  fight_club.run
end