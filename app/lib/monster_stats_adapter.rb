# Adapter for view
class MonsterStatsAdapter
  def adapt(monster_stats)
    return nil if monster_stats.nil?
    tracker = {}
    all_stats = []
    monster_stats.keys.each do |location_name|
      next if tracker[location_name].present?
      tracker[location_name] = true
      stats = { origin_name: location_name }
      stats.merge!(monster_stats[location_name]) if monster_stats[location_name].present?
      all_stats << stats
    end
    all_stats.sort_by { |v| v[:origin_name] }
  end
end