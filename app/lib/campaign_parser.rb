class CampaignParser
  attr_reader :errors

  def initialize(campaign_uuid)
    @campaign_uuid = campaign_uuid
    @errors = []
  end

  def parse(campaign_json_in_mem)
    campaign_hash = JSON.parse(campaign_json_in_mem)
    Rails.logger.info("Parsed campaign json. campaign_uuid=#{@campaign_uuid}")
    campaign_hash
  end

  def build_campaign_container(campaign_hash)
    @errors = []
    container = create_empty_container(campaign_hash)
    custom_monsters = {}
    campaign_hash['userMonsters'].each do |monster|
      internal_name = monster['internalName']
      next if internal_name.blank?
      custom_monsters[internal_name] = { reference_definition: monster['referenceDefinition'] }
    end
    campaign_hash['userLocations'].each_with_index do |user_location, index|
      location_name = user_location['title']
      if location_name.blank?
        error_message = "Failed to process UserLocation due to empty location name. index=#{index} campaign_uuid=#{@campaign_uuid}".freeze
        Rails.logger.warn(error_message)
        @errors << error_message
        next
      end
      location = Campaign::Location.new(location_name)
      container.locations << location
      location.campaign_start = user_location['campaignStart'] == true
      user_location['userRooms'].each do |room|
        begin
          room['userGadgets'].each do |gadget|
            next if gadget['gadgetBlueprintName'].blank?
            if gadget['gadgetBlueprintName'] == "Entrance"
              location.entrances << create_entrance(location_name, gadget)
            elsif gadget['gadgetBlueprintName'] =~ /Exit/
              location.exits << create_exits(location_name, gadget)
            elsif gadget['gadgetBlueprintName'] =~ /Monster/
              location.monsters << create_monster(location_name, gadget, custom_monsters)
            elsif gadget['gadgetBlueprintName'] =~ /GrantXP/
              location.xp_grants << create_xp_grant(location_name, gadget)
            end
          end
        rescue StandardError => err
          error_message = "Failed to process UserLocation campaign_uuid=#{@campaign_uuid} index=#{index}".freeze
          @errors << error_message
          Rails.logger.warn("#{error_message} error=#{err.message} trace=#{err.backtrace&.join('\n')&.truncate(120)}")
        end
      end
    end
    Rails.logger.info("Finished processing. error_count=#{@errors.size} campaign_uuid=#{@campaign_uuid}")
    container
  end

  def create_xp_grant(location_name, grant_xp_gadget)
    return 0 if grant_xp_gadget.blank?
    xp_amount = 0
    flat_gain = false
    grant_xp_gadget['parameterValues'].each do |param|
      case param['gadgetParameterDescriptionName']
      when 'FlatGain'
        flat_gain = param['boolValue']
      when 'XpGain'
        xp_amount = param['intValue']
      end
    end
    # Ignore RequiredLevel xp grants
    xp_amount = 0 unless flat_gain
    xp_amount
  end

  def create_monster(location_name, monster_gadget, custom_monsters)
    monster = Campaign::Monster.new(location_name)
    monster.gadgetBlueprintName = monster_gadget['gadgetBlueprintName']
    monster_gadget['parameterValues'].each do |param|
      case param['gadgetParameterDescriptionName']
      when 'Creature'
        monster.creature = param['stringValue']
      when 'EncounterGroup'
        monster.encounter_group = param['boolValue']
      when 'GroupIndex'
        monster.group_index = param['intValue']
      end
    end
    refdef = custom_monsters.has_key?(monster.creature) ? custom_monsters[monster.creature][:reference_definition] : nil
    monster.reference_definition = refdef || monster.creature
    monster.cr = MonsterCr.find_cr(monster.reference_definition)
    monster
  end

  def create_entrance(location_name, entrance_gadget)
    entrance = Campaign::Entrance.new(location_name)
    index_param = entrance_gadget['parameterValues'].find { |param| param['gadgetParameterDescriptionName'] == 'EntranceIndex' }
    raise StandardError, "Entrance missing index value." if index_param.blank?
    entrance.index = index_param['intValue']
    entrance
  end

  def create_empty_container(campaign_hash)
    container = Campaign::Container.new
    container.title = campaign_hash['title']
    container.author = campaign_hash['author']
    container.author_version = campaign_hash['authorVersion']
    container.uuid = @campaign_uuid
    container
  end

  def create_exits(location_name, exit_gadget)
    destination_entrance = nil
    entrance_index = nil
    entrances = []
    exit_gadget['parameterValues'].each do |param|
      # Other values of interest: Param_Enabled, ExitLore
      case param['gadgetParameterDescriptionName']
      when 'DestinationLocation'
        if param['stringValue'].blank?
          # An empty destination location is exit to victory (end campaign).
          entrances << nil
        else
          destination_entrance = Campaign::Entrance.new(param['stringValue'])
        end
      when 'EntranceIndex'
        entrance_index = param['intValue']
      when 'LocationsList'
        param['destinationsList'].each do |dest|
          if dest['userLocationName'].blank?
            entrances << nil
          else
            ent = Campaign::Entrance.new(dest['userLocationName'])
            ent.displayed_title = dest['displayedTitle']
            ent.index = dest['entranceIndex']
            entrances << ent
          end
        end
      end
    end
    if entrance_index.present? && destination_entrance.present?
      destination_entrance.index = entrance_index
      entrances << destination_entrance
    end
    location_exit = Campaign::Exit.new(location_name)
    location_exit.destination_entrances.concat(entrances)
    location_exit
  end
end