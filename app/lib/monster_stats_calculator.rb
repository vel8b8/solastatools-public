class MonsterStatsCalculator
  def calc_monster_stats(location)
    stats = {}
    cr_total = 0
    monster_crs = []
    encounter_group_index_tracker = {}
    location.monsters.each do |monster|
      next if monster.cr.blank?
      stats[:min_monster_cr] = monster.cr if stats[:min_monster_cr].blank? || monster.cr < stats[:min_monster_cr]
      stats[:max_monster_cr] = monster.cr if stats[:max_monster_cr].blank? || monster.cr > stats[:max_monster_cr]
      cr_total += monster.cr
      monster_crs << monster.cr
      if monster.encounter_group
        encounter_group_index_tracker[monster.group_index] ||= 0
        encounter_group_index_tracker[monster.group_index] += 1
      end
    end
    stats[:monster_cr_list] = monster_crs
    stats[:mean_monster_cr] = cr_total / (1.0 * location.monsters.size) if location.monsters.size > 0
    stats[:median_monster_cr] = MissingMath.median(monster_crs)
    stats[:total_monsters] = location.monsters.size
    stats[:encounter_groups] = encounter_group_index_tracker.size
    group_counts = encounter_group_index_tracker.values
    stats[:mean_encounter_monsters] = group_counts.sum(0.0) / group_counts.size if group_counts.size > 0
    stats[:max_encounter_monsters] = group_counts.max
    stats[:min_encounter_monsters] = group_counts.min
    stats[:median_encounter_monsters] = MissingMath.median(group_counts)
    stats
  end
end