class Campaign::Entrance
  attr_accessor :location_name, :index, :displayed_title

  def initialize(location_name, index = nil, displayed_title = nil)
    @location_name = location_name
    raise StandardError, "Empty location name." if @location_name.blank?
    @index = index
    @displayed_title = displayed_title
  end
end