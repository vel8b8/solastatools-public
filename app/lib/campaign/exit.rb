class Campaign::Exit
  attr_accessor :location_name, :gadget_blueprint_name, :destination_entrances

  def initialize(location_name, gadget_blueprint_name = nil, destination_entrances = [])
    @location_name = location_name
    raise StandardError, "Empty location name." if @location_name.blank?
    @gadget_blueprint_name = gadget_blueprint_name
    @destination_entrances = destination_entrances
  end
end
