class Validation::LocationLink
  attr_accessor :origin_name, :dest_name, :dest_entrance_index, :dest_name_valid, :dest_index_valid, :campaign_end

  def initialize(origin_name)
    @origin_name = origin_name
    @campaign_end = false
  end

  def ==(other)
    @origin_name == other.origin_name && @dest_name == other.dest_name \
      && @dest_entrance_index == other.dest_entrance_index
  end

  def hash
    Digest::MD5.hexdigest("#{@origin_name}:#{@dest_name}:#{@dest_entrance_index}")
  end
end
