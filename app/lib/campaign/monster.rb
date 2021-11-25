class Campaign::Monster
  attr_accessor :location_name, :gadgetBlueprintName, :reference_definition, :creature, :encounter_group, :group_index, :cr

  def initialize(location_name)
    @location_name = location_name
  end
end