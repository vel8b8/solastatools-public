class Campaign::Location
  attr_accessor :location_name, :campaign_start, :exits, :entrances, :monsters, :xp_grants

  def initialize(location_name)
    @location_name = location_name
    raise StandardError, "Empty location name." if @location_name.blank?
    @campaign_start = false
    @exits = []
    @entrances = []
    @monsters = []
    @xp_grants = []
  end
end