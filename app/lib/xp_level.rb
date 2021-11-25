class XpLevel
  def self.xp_to_level(xp)
    @@xp_level_map ||= init_xp_map
    level_achieved = 1
    @@xp_level_map.keys.each do|level_xp|
      break if level_xp > xp
      level_achieved = @@xp_level_map[level_xp]
    end
    level_achieved
  end

  def self.init_xp_map
    {
      0 => 1,
      300 => 2,
      900 => 3,
      2700 => 4,
      6500 => 5,
      14000 => 6,
      23000 => 7,
      34000 => 8,
      48000 => 9,
      64000 => 10,
      85000 => 11,
      100000 => 12,
      120000 => 13,
      140000 => 14,
      165000 => 15,
      195000 => 16,
      225000 => 17,
      265000 => 18,
      305000 => 19,
      355000 => 20
    }
  end
end