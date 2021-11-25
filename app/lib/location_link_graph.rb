class LocationLinkGraph
  attr_accessor :nodes, :edges

  def initialize
    @nodes = []
    @edges = []
  end

  class GraphNode
    attr_accessor :id, :label, :color, :font

    def initialize(id, label, color)
      @id = id
      @label = label
      @color = color
      @font = { face: "sans-serif" }
    end
  end

  class GraphEdge
    attr_accessor :from, :to, :arrows

    def initialize(from, to)
      @from = from
      @to = to
      @arrows = "to"
    end
  end

  def nodes_json
    @nodes.to_json.html_safe
  end

  def edges_json
    @edges.to_json.html_safe
  end
  
  def self.transform(location_links)
    location_to_node_id = {}
    invalid_locations = {}
    graph_data = LocationLinkGraph.new
    campaign_exit_id = 0
    location_links.each do |link|
      next_node_id = location_to_node_id.keys.size
      unless location_to_node_id.has_key?(link.origin_name)
        location_to_node_id[link.origin_name] = next_node_id
        next_node_id = location_to_node_id.keys.size
      end
      dest_name = link.dest_name
      if dest_name.blank?
        dest_name = "(Victory #{campaign_exit_id})"
        campaign_exit_id += 1
      end
      unless location_to_node_id.has_key?(dest_name)
        location_to_node_id[dest_name] = next_node_id
        next_node_id = location_to_node_id.keys.size
      end
      invalid_locations[link.origin_name] = true unless link.dest_index_valid && link.dest_name_valid
      from_id = location_to_node_id[link.origin_name]
      to_id = location_to_node_id[dest_name]
      graph_data.edges << GraphEdge.new(from_id, to_id)
    end
    location_to_node_id.keys.each do |location_name|
      id = location_to_node_id[location_name]
      color = invalid_locations.has_key?(location_name) ? "#feecf0" : "#effaf3"
      graph_data.nodes << GraphNode.new(id, location_name, color)
    end
    graph_data
  end
end