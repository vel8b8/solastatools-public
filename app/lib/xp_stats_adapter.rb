class XpStatsAdapter
  PARTY_MEMBERS = 4

  # returns: XP per location (to be divided by number of party members)
  def adapt(monster_stats, xp_grants)
    xp_stats = {}
    xp_grants&.keys&.each do |location_name|
      next if xp_grants[location_name].blank?
      xp_stats[location_name] ||= {}
      xp_stats[location_name][:granted_xp] ||= 0
      xp_stats[location_name][:total_xp] ||= 0
      # GrantXP gadget grants the xp amount to each party member, does not divide it across the party.
      grant_sum = xp_grants[location_name].sum * PARTY_MEMBERS
      xp_stats[location_name][:granted_xp] += grant_sum
      xp_stats[location_name][:total_xp] += grant_sum
    end
    monster_stats&.keys&.each do |location_name|
      next if monster_stats[location_name].blank?
      xp_stats[location_name] ||= {}
      xp_stats[location_name][:monster_xp] ||= 0
      xp_stats[location_name][:total_xp] ||= 0
      monster_stats[location_name][:monster_cr_list]&.each do |cr|
        next if cr.blank?
        # Monster xp is divided across the party.
        monster_xp = SrdCrXp.xp_for_cr(cr)
        if monster_xp.present?
          xp_stats[location_name][:monster_xp] += monster_xp
          xp_stats[location_name][:total_xp] += monster_xp
        end
      end
    end
    # TODO clean up this mess
    adapted = []
    xp_stats.keys.each do |location_name|
      next if xp_stats[location_name].blank?
      h = { origin_name: location_name }
      h.merge!(xp_stats[location_name])
      adapted << h
    end
    adapted
  end
end