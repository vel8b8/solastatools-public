class FightClubWorker
  include Sidekiq::Worker

  def perform(upload_id)
    begin
      execute!(upload_id)
    rescue StandardError => err
      Rails.logger.error("FightClubWorker failed. upload_id=#{upload_id} error=#{err&.message} trace=#{err.backtrace&.join('\n')&.truncate(300)}")
    end
  end

  def execute!(upload_id)
    campaign_upload = CampaignUpload.find_by_id(upload_id)
    if campaign_upload.blank?
      Rails.logger.error("FightClubWorker failed to find CampaignUpload. upload_id=#{upload_id}")
      return
    end
    persistence = Campaign::Persistence.new
    campaign_container = persistence.load_container(campaign_upload.uuid)
    raise StandardError, "Failed to load campaign container. campaign_upload_uuid=#{campaign_upload.uuid}" if campaign_container.blank?
    solasta_monster_defs = Sim::SolastaBlueprints.solasta_monster_definitions
    custom_monster_parser = CustomMonsterParser.new(solasta_monster_defs)
    custom_monster_defs = custom_monster_parser.create_monster_definitions(campaign_container.custom_monsters)
    output_stats = generate_output_stats(campaign_container, custom_monster_defs, solasta_monster_defs)
    persistence.save_combat_stats(campaign_upload.uuid, output_stats)
    output_stats
  end

  def generate_output_stats(campaign_container, custom_monster_defs, solasta_monster_defs)
    output_stats = { custom_monster_stats: [], encounter_stats: [], ungrouped_stats: [] }
    # Sim::MonsterDefinition
    custom_monster_defs.each do |custom_monster|
      monster_party = [custom_monster]
      stats_from_run = {
        encounter_index: nil,
        location_name: nil,
        stats: run_fight_club(monster_party)
      }
      output_stats[:custom_monster_stats] << stats_from_run
    end

    # Sim::MonsterDefinition
    monster_lookup = custom_monster_defs.inject({}) { |h, monster| h[monster.internal_name] = monster; h }
    solasta_monster_defs.values.each do |monster|
      monster_lookup[monster.internal_name] = monster unless monster_lookup.has_key?(monster.internal_name)
    end
    campaign_container.locations.each do |location|
      encounters = create_encounter_groups(location)
      encounters[:grouped].each_pair do |encounter_index, monster_list|
        monster_party = create_monster_party(monster_list, monster_lookup)
        stats_from_run = {
          encounter_index: encounter_index,
          location_name: location.location_name,
          stats: run_fight_club(monster_party)
        }
        output_stats[:encounter_stats] << stats_from_run
      end
      encounters[:ungrouped].each do |monster|
        monster_party = create_monster_party([monster], monster_lookup)
        stats_from_run = {
          encounter_index: nil,
          location_name: location.location_name,
          stats: run_fight_club(monster_party)
        }
        output_stats[:ungrouped_stats] << stats_from_run
      end
    end
    output_stats
  end

  def run_fight_club(monster_party)
    fight_club = Sim::FightClub.new
    fight_club.estimated_difficulty(monster_party, false)
  end

  def create_encounter_groups(campaign_location)
    grouped_encounters = {}
    ungrouped_encounters = []
    # Campaign::Monster
    campaign_location.monsters.each do |monster|
      if monster.group_index.present?
        grouped_encounters[monster.group_index] ||= []
        grouped_encounters[monster.group_index] << monster
      else
        ungrouped_encounters << monster
      end
    end
    { grouped: grouped_encounters, ungrouped: ungrouped_encounters }
  end

  # Convert from Campaign::Monster to Sim::MonsterDefinition
  #
  # monster_list: [Campaign::Monster]
  def create_monster_party(monster_list, monster_lookup)
    party = []
    monster_list.each do |monster|
      unless monster_lookup.has_key?(monster.creature)
        Rails.logger.warn("FightClubWorker failed to find monster. creature=#{monster.creature}")
        next
      end
      party << monster_lookup[monster.creature]
    end
    party
  end
end