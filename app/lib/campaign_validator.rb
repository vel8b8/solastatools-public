class CampaignValidator
  class Results
    attr_accessor :errors, :validation_links, :monster_stats, :xp_grants

    def initialize(validation_links, monster_stats, xp_grants, errors)
      @validation_links = validation_links
      @monster_stats = monster_stats
      @xp_grants = xp_grants
      @errors = errors
    end
  end

  attr_reader :errors

  def initialize(initial_errors = [])
    @initial_errors = initial_errors
  end

  def validate(campaign_container)
    @errors = @initial_errors.clone
    Rails.logger.info("Validating campaign uuid=#{campaign_container.uuid} title=#{campaign_container.title}")
    location_hash = build_location_hash(campaign_container)
    entrance_hash = build_entrance_hash(location_hash)
    results = build_results(location_hash, entrance_hash)
    Rails.logger.info("Completed validation location_links_validated=#{results.validation_links&.size} uuid=#{campaign_container.uuid} title=#{campaign_container.title}")
    results
  end

  def build_results(location_hash, entrance_hash)
    validation_links = []
    monster_stats = {}
    xp_grants = {}
    location_hash.keys.each do |location_name|
      location = location_hash[location_name]
      monster_stats[location_name] = MonsterStatsCalculator.new.calc_monster_stats(location) unless monster_stats.has_key?(location_name)
      xp_grants[location_name] = location.xp_grants unless xp_grants.has_key?(location_name)
      location.exits.each do |location_exit|
        location_exit.destination_entrances.each do |dest_entrance|
          link = Validation::LocationLink.new(location_name)
          if dest_entrance.blank?
            # terminal exit, ends campaign
            link.campaign_end = true
            link.dest_name = nil
            link.dest_entrance_index = 0
            link.dest_name_valid = true
            link.dest_index_valid = true
          else
            link.dest_name = dest_entrance.location_name
            link.dest_entrance_index = dest_entrance.index
            link.dest_name_valid = location_hash.has_key?(dest_entrance.location_name)
            entloc = entrance_hash[dest_entrance.location_name]
            link.dest_index_valid = entloc.present? && entloc.has_key?(dest_entrance.index)
            add_error("Invalid destination location. origin=#{location_name} destination=#{dest_entrance.location_name}") unless link.dest_name_valid
            add_error("Invalid destination entrance index. origin=#{location_name} destination=#{dest_entrance.location_name} entrance_index=#{dest_entrance.index}") unless link.dest_index_valid
          end
          validation_links << link
        end
      end
    end
    validation_links = dedup_links(validation_links)
    CampaignValidator::Results.new(validation_links, monster_stats, xp_grants, @errors.clone)
  end

  def dedup_links(validation_links)
    validation_links.inject({}) { |h, link| h[link.hash] = link; h }.values
  end

  def build_entrance_hash(location_hash)
    entrance_hash = {}
    location_hash.keys.each do |location_name|
      location = location_hash[location_name]
      location.entrances.each_with_index do |entrance, ent_count|
        if entrance.index.blank?
          add_error("Missing entrance index. location_name=#{location_name} entrance_count=#{ent_count}")
        else
          entrance_hash[location_name] ||= {}
          entrance_hash[location_name][entrance.index] = true
        end
      end
    end
    entrance_hash
  end

  def build_location_hash(campaign_container)
    location_hash = {}
    campaign_container.locations.each_with_index do |location, index|
      if location.location_name.blank?
        add_error("Missing location name. location_index=#{index}")
      elsif location_hash.has_key?(location.location_name)
        add_error("Duplicate location_name=#{location.location_name} location_index=#{index}")
      else
        location_hash[location.location_name] = location
      end
    end
    location_hash
  end

  def add_error(error_message)
    @errors << error_message.freeze
  end
end