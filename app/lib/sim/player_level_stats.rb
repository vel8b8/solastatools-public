class Sim::PlayerLevelStats
  PROFICIENCY_MODIFIER_TABLE = {
    1 => 2,
    2 => 2,
    3 => 2,
    4 => 2,
    5 => 3,
    6 => 3,
    7 => 3,
    8 => 3,
    9 => 4,
    10 => 4,
    11 => 4,
    12 => 4,
    13 => 5,
    14 => 5,
    15 => 5,
    16 => 5,
    17 => 6,
    18 => 6,
    19 => 6,
    20 => 6
  }

  # 18..20 in primary stat, taking ability improvement at level 4 and 8
  def ability_modifier(player_level)
    return 3 if player_level < 4
    return 4 if player_level < 8
    5
  end

  # simulate melee/ranged magic weapons acquired by players
  def magic_weapon_bonus(player_level)
    return 0 if player_level < 4
    return 1 if player_level < 6
    return 2 if player_level < 9
    return 3 if player_level < 12
    return 4 if player_level < 15
    5
  end

  def create_player_level_stats
    player_stats = {
      1 => {
        fighter: {
          con_bonus: 2,
          ac: 16,
          attacks: {
            # create_attack(iterations, dice_number, die_type, bonus_damage, to_hit_bonus)
            melee: [Sim::MonsterDefinition.create_attack(1, 1, "D12", magic_weapon_bonus(1) + ability_modifier(1), magic_weapon_bonus(1) + ability_modifier(1)+PROFICIENCY_MODIFIER_TABLE[1])],
            ranged: [],
            magic_ranged: []
          }
        },
        rogue: {
          con_bonus: 1,
          ac: 14,
          attacks: {
            # Condensed rogue sneak attack into melee attack list. This increases the damage dice by +1 beyond what is expected. L1: 2d6 L5: 3d6
            melee: [Sim::MonsterDefinition.create_attack(1, 1, "D4", 0, ability_modifier(1)+PROFICIENCY_MODIFIER_TABLE[1]), 
              Sim::MonsterDefinition.create_attack(1, 2, "D6", magic_weapon_bonus(1) + ability_modifier(1), magic_weapon_bonus(1) + ability_modifier(1)+PROFICIENCY_MODIFIER_TABLE[1])],
            ranged: [],
            magic_ranged: []
          }
        },
        wizard: {
          con_bonus: 1,
          ac: 12,
          attacks: {
            melee: [],
            ranged: [],
            # Fire bolt
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 1, "D10", 0, ability_modifier(1)+PROFICIENCY_MODIFIER_TABLE[1])]
          }
        },
        cleric: {
          con_bonus: 2,
          ac: 16,
          attacks: {
            melee: [],
            ranged: [],
            # Sacred flame
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 1, "D8", 0, ability_modifier(1)+PROFICIENCY_MODIFIER_TABLE[1])]
          }
        }
      },
      2 => {
        fighter: {
          con_bonus: 2,
          ac: 16,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(1, 1, "D12", magic_weapon_bonus(2) + ability_modifier(2), magic_weapon_bonus(2) + ability_modifier(2)+PROFICIENCY_MODIFIER_TABLE[2])],
            ranged: [],
            magic_ranged: []
          }
        },
        rogue: {
          con_bonus: 1,
          ac: 14,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(1, 1, "D4", 0, PROFICIENCY_MODIFIER_TABLE[2]), 
              Sim::MonsterDefinition.create_attack(1, 2, "D6", magic_weapon_bonus(2) + ability_modifier(2), magic_weapon_bonus(2) + ability_modifier(2)+PROFICIENCY_MODIFIER_TABLE[2])],
            ranged: [],
            magic_ranged: []
          }
        },
        wizard: {
          con_bonus: 1,
          ac: 12,
          attacks: {
            melee: [],
            ranged: [],
            # Fire bolt
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 1, "D10", 0, ability_modifier(2)+PROFICIENCY_MODIFIER_TABLE[2])]
          }
        },
        cleric: {
          con_bonus: 2,
          ac: 16,
          attacks: {
            melee: [],
            ranged: [],
            # Sacred flame
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 1, "D8", 0, ability_modifier(2)+PROFICIENCY_MODIFIER_TABLE[2])]
          }
        }
      },
      3 => {
        fighter: {
          con_bonus: 2,
          ac: 17,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(1, 1, "D12", magic_weapon_bonus(3) + ability_modifier(3), magic_weapon_bonus(3) + ability_modifier(3)+PROFICIENCY_MODIFIER_TABLE[3])],
            ranged: [],
            magic_ranged: []
          }
        },
        rogue: {
          con_bonus: 1,
          ac: 15,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(1, 1, "D4", 0, ability_modifier(3)+PROFICIENCY_MODIFIER_TABLE[3]), 
              Sim::MonsterDefinition.create_attack(1, 2, "D6", magic_weapon_bonus(3) + ability_modifier(2), magic_weapon_bonus(3) + ability_modifier(3)+PROFICIENCY_MODIFIER_TABLE[3])],
            ranged: [],
            magic_ranged: []
          }
        },
        wizard: {
          con_bonus: 1,
          ac: 12,
          attacks: {
            melee: [],
            ranged: [],
            # Fire bolt
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 1, "D10", 0, ability_modifier(3)+PROFICIENCY_MODIFIER_TABLE[3])]
          }
        },
        cleric: {
          con_bonus: 2,
          ac: 16,
          attacks: {
            melee: [],
            ranged: [],
            # Sacred flame
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 1, "D8", 0, ability_modifier(3)+PROFICIENCY_MODIFIER_TABLE[3])]
          }
        }
      },
      4 => {
        fighter: {
          con_bonus: 2,
          ac: 17,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(1, 1, "D12", magic_weapon_bonus(4) + ability_modifier(4), magic_weapon_bonus(4) + ability_modifier(4)+PROFICIENCY_MODIFIER_TABLE[4])],
            ranged: [],
            magic_ranged: []
          }
        },
        rogue: {
          con_bonus: 1,
          ac: 15,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(1, 1, "D4", 0, ability_modifier(4)+PROFICIENCY_MODIFIER_TABLE[4]), 
              Sim::MonsterDefinition.create_attack(1, 3, "D6", magic_weapon_bonus(4) + ability_modifier(4), magic_weapon_bonus(4) + ability_modifier(4)+PROFICIENCY_MODIFIER_TABLE[4])],
            ranged: [],
            magic_ranged: []
          }
        },
        wizard: {
          con_bonus: 1,
          ac: 12,
          attacks: {
            melee: [],
            ranged: [],
            # Fire bolt with +1 bonus dice early due to shock arcanist
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 2, "D10", 0, ability_modifier(4)+PROFICIENCY_MODIFIER_TABLE[4])]
          }
        },
        cleric: {
          con_bonus: 2,
          ac: 16,
          attacks: {
            melee: [],
            ranged: [],
            # Sacred flame
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 1, "D8", 0, ability_modifier(4)+PROFICIENCY_MODIFIER_TABLE[4])]
          }
        }
      },
      5 => {
        fighter: {
          con_bonus: 3,
          ac: 18,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(2, 1, "D12", magic_weapon_bonus(5) + ability_modifier(5), magic_weapon_bonus(5) + ability_modifier(5)+PROFICIENCY_MODIFIER_TABLE[5])],
            ranged: [],
            magic_ranged: []
          }
        },
        rogue: {
          con_bonus: 1,
          ac: 16,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(1, 1, "D4", 0, ability_modifier(5)+PROFICIENCY_MODIFIER_TABLE[5]), 
              Sim::MonsterDefinition.create_attack(1, 4, "D6", magic_weapon_bonus(5) + ability_modifier(5), magic_weapon_bonus(5) + ability_modifier(5)+PROFICIENCY_MODIFIER_TABLE[5])],
            ranged: [],
            magic_ranged: []
          }
        },
        wizard: {
          con_bonus: 1,
          ac: 12,
          attacks: {
            melee: [],
            ranged: [],
            # Scorching ray
            magic_ranged: [Sim::MonsterDefinition.create_attack(3, 2, "D6", 0, ability_modifier(5)+PROFICIENCY_MODIFIER_TABLE[8])]
          }
        },
        cleric: {
          con_bonus: 2,
          ac: 17,
          attacks: {
            melee: [],
            ranged: [],
            # Sacred flame
            # Spirit guardians: no save but should be save for half. Simulating distance (not all enemies affected) and saves (half damage) by reducing damage dice below D8->D6.
            # The +100 to attack roll is so it always hits
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 2, "D8", 0, ability_modifier(5)+PROFICIENCY_MODIFIER_TABLE[5]), 
              Sim::MonsterDefinition.create_attack(1, 3, "D6", 0, 100)]
          }
        }
      },
      6 => {
        fighter: {
          con_bonus: 3,
          ac: 18,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(2, 1, "D12", magic_weapon_bonus(6) + ability_modifier(6), magic_weapon_bonus(6) + ability_modifier(6)+PROFICIENCY_MODIFIER_TABLE[5])],
            ranged: [],
            magic_ranged: []
          }
        },
        rogue: {
          con_bonus: 1,
          ac: 16,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(1, 1, "D4", 0, ability_modifier(6)+PROFICIENCY_MODIFIER_TABLE[5]), 
              Sim::MonsterDefinition.create_attack(1, 4, "D6", magic_weapon_bonus(6) + ability_modifier(6), magic_weapon_bonus(6) + ability_modifier(6)+PROFICIENCY_MODIFIER_TABLE[5])],
            ranged: [],
            magic_ranged: []
          }
        },
        wizard: {
          con_bonus: 1,
          ac: 12,
          attacks: {
            melee: [],
            ranged: [],
            # Scorching ray
            magic_ranged: [Sim::MonsterDefinition.create_attack(3, 2, "D6", 0, ability_modifier(6)+PROFICIENCY_MODIFIER_TABLE[8])]
          }
        },
        cleric: {
          con_bonus: 2,
          ac: 17,
          attacks: {
            melee: [],
            ranged: [],
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 2, "D8", 0, ability_modifier(6)+PROFICIENCY_MODIFIER_TABLE[5]), 
              Sim::MonsterDefinition.create_attack(1, 3, "D6", 0, 100)]
          }
        }
      },
      7 => {
        fighter: {
          con_bonus: 3,
          ac: 18,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(2, 1, "D12", magic_weapon_bonus(7) + ability_modifier(7), magic_weapon_bonus(7) + ability_modifier(7)+PROFICIENCY_MODIFIER_TABLE[5])],
            ranged: [],
            magic_ranged: []
          }
        },
        rogue: {
          con_bonus: 1,
          ac: 16,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(1, 1, "D4", 0, ability_modifier(7)+PROFICIENCY_MODIFIER_TABLE[5]), 
              Sim::MonsterDefinition.create_attack(1, 4, "D6", magic_weapon_bonus(7) + ability_modifier(7), magic_weapon_bonus(7) + ability_modifier(7)+PROFICIENCY_MODIFIER_TABLE[5])],
            ranged: [],
            magic_ranged: []
          }
        },
        wizard: {
          con_bonus: 1,
          ac: 12,
          attacks: {
            melee: [],
            ranged: [],
            # Upcast scorching ray
            magic_ranged: [Sim::MonsterDefinition.create_attack(3, 3, "D6", 0, ability_modifier(7)+PROFICIENCY_MODIFIER_TABLE[8])]
          }
        },
        cleric: {
          con_bonus: 2,
          ac: 17,
          attacks: {
            melee: [],
            ranged: [],
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 2, "D8", 0, ability_modifier(7)+PROFICIENCY_MODIFIER_TABLE[5]), 
              Sim::MonsterDefinition.create_attack(1, 3, "D6", 0, 100)]
          }
        }
      },
      8 => {
        fighter: {
          con_bonus: 4,
          ac: 19,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(2, 1, "D12", magic_weapon_bonus(8) + ability_modifier(8), magic_weapon_bonus(8) + ability_modifier(8)+PROFICIENCY_MODIFIER_TABLE[8])],
            ranged: [],
            magic_ranged: []
          }
        },
        rogue: {
          con_bonus: 1,
          ac: 17,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(1, 1, "D4", 0, ability_modifier(8)+PROFICIENCY_MODIFIER_TABLE[8]), 
              Sim::MonsterDefinition.create_attack(1, 5, "D6", magic_weapon_bonus(8) + ability_modifier(8), magic_weapon_bonus(8) + ability_modifier(8)+PROFICIENCY_MODIFIER_TABLE[8])],
            ranged: [],
            magic_ranged: []
          }
        },
        wizard: {
          con_bonus: 1,
          ac: 12,
          attacks: {
            melee: [],
            ranged: [],
            # Upcast scorching ray
            magic_ranged: [Sim::MonsterDefinition.create_attack(4, 3, "D6", 0, ability_modifier(8)+PROFICIENCY_MODIFIER_TABLE[8])]
          }
        },
        cleric: {
          con_bonus: 2,
          ac: 17,
          attacks: {
            melee: [],
            ranged: [],
            # Sacred flame
            # Upcast spirit guardian
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 2, "D8", 0, ability_modifier(8)+PROFICIENCY_MODIFIER_TABLE[8]), 
              Sim::MonsterDefinition.create_attack(1, 4, "D6", 0, 100)]
          }
        }
      },
      9 => {
        fighter: {
          con_bonus: 4,
          ac: 19,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(2, 1, "D12", magic_weapon_bonus(9) + ability_modifier(9), magic_weapon_bonus(9) + ability_modifier(9)+PROFICIENCY_MODIFIER_TABLE[9])],
            ranged: [],
            magic_ranged: []
          }
        },
        rogue: {
          con_bonus: 1,
          ac: 17,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(1, 1, "D4", 0, ability_modifier(9)+PROFICIENCY_MODIFIER_TABLE[9]), 
              Sim::MonsterDefinition.create_attack(1, 5, "D6", magic_weapon_bonus(9) + ability_modifier(9), magic_weapon_bonus(9) + ability_modifier(9)+PROFICIENCY_MODIFIER_TABLE[9])],
            ranged: [],
            magic_ranged: []
          }
        },
        wizard: {
          con_bonus: 1,
          ac: 12,
          attacks: {
            melee: [],
            ranged: [],
            # Upcast scorching ray
            magic_ranged: [Sim::MonsterDefinition.create_attack(4, 4, "D6", 0, ability_modifier(9)+PROFICIENCY_MODIFIER_TABLE[9])]
          }
        },
        cleric: {
          con_bonus: 2,
          ac: 17,
          attacks: {
            melee: [],
            ranged: [],
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 2, "D8", 0, ability_modifier(9)+PROFICIENCY_MODIFIER_TABLE[9]), 
              Sim::MonsterDefinition.create_attack(1, 4, "D6", 0, 100)]
          }
        }
      },
      10 => {
        fighter: {
          con_bonus: 4,
          ac: 20,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(2, 1, "D12", magic_weapon_bonus(10) + ability_modifier(10), magic_weapon_bonus(10) + ability_modifier(10)+PROFICIENCY_MODIFIER_TABLE[10])],
            ranged: [],
            magic_ranged: []
          }
        },
        rogue: {
          con_bonus: 1,
          ac: 17,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(1, 1, "D4", 0, ability_modifier(10)+PROFICIENCY_MODIFIER_TABLE[10]), 
              Sim::MonsterDefinition.create_attack(1, 6, "D6", magic_weapon_bonus(10) + ability_modifier(10), magic_weapon_bonus(10) + ability_modifier(10)+PROFICIENCY_MODIFIER_TABLE[10])],
            ranged: [],
            magic_ranged: []
          }
        },
        wizard: {
          con_bonus: 1,
          ac: 12,
          attacks: {
            melee: [],
            ranged: [],
            # Lightning bolt, less dice to represent some saves
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 6, "D6", 0, 100)]
          }
        },
        cleric: {
          con_bonus: 2,
          ac: 19,
          attacks: {
            melee: [],
            ranged: [],
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 2, "D8", 0, ability_modifier(10)+PROFICIENCY_MODIFIER_TABLE[10]), 
              Sim::MonsterDefinition.create_attack(1, 5, "D6", 0, 100)]
          }
        }
      },
      11 => {
        fighter: {
          con_bonus: 4,
          ac: 20,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(2, 1, "D12", magic_weapon_bonus(11) + ability_modifier(11), magic_weapon_bonus(11) + ability_modifier(11)+PROFICIENCY_MODIFIER_TABLE[11])],
            ranged: [],
            magic_ranged: []
          }
        },
        rogue: {
          con_bonus: 1,
          ac: 17,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(1, 1, "D4", 0, ability_modifier(11)+PROFICIENCY_MODIFIER_TABLE[11]), 
              Sim::MonsterDefinition.create_attack(1, 6, "D6", magic_weapon_bonus(11) + ability_modifier(11), magic_weapon_bonus(11) + ability_modifier(11)+PROFICIENCY_MODIFIER_TABLE[11])],
            ranged: [],
            magic_ranged: []
          }
        },
        wizard: {
          con_bonus: 1,
          ac: 12,
          attacks: {
            melee: [],
            ranged: [],
            # Lightning bolt, less dice to represent some saves
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 6, "D6", 0, 100)]
          }
        },
        cleric: {
          con_bonus: 2,
          ac: 19,
          attacks: {
            melee: [],
            ranged: [],
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 3, "D8", 0, ability_modifier(11)+PROFICIENCY_MODIFIER_TABLE[10]), 
              Sim::MonsterDefinition.create_attack(1, 5, "D6", 0, 100)]
          }
        }
      },
      12 => {
        fighter: {
          con_bonus: 5,
          ac: 21,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(3, 1, "D12", magic_weapon_bonus(12) + ability_modifier(12), magic_weapon_bonus(12) + ability_modifier(12)+PROFICIENCY_MODIFIER_TABLE[12])],
            ranged: [],
            magic_ranged: []
          }
        },
        rogue: {
          con_bonus: 1,
          ac: 18,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(1, 1, "D4", 0, ability_modifier(12)+PROFICIENCY_MODIFIER_TABLE[12]), 
              Sim::MonsterDefinition.create_attack(1, 7, "D6", magic_weapon_bonus(12) + ability_modifier(12), magic_weapon_bonus(12) + ability_modifier(12)+PROFICIENCY_MODIFIER_TABLE[12])],
            ranged: [],
            magic_ranged: []
          }
        },
        wizard: {
          con_bonus: 1,
          ac: 12,
          attacks: {
            melee: [],
            ranged: [],
            # Lightning bolt, no save
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 8, "D6", 0, 100)]
          }
        },
        cleric: {
          con_bonus: 2,
          ac: 19,
          attacks: {
            melee: [],
            ranged: [],
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 3, "D8", 0, ability_modifier(12)+PROFICIENCY_MODIFIER_TABLE[12]), 
              Sim::MonsterDefinition.create_attack(1, 5, "D6", 0, 100)]
          }
        }
      },
      # We skip levels here. The estimates are coarse at higher levels due to the complexity of combat. There's no need for granularity.
      15 => {
        fighter: {
          con_bonus: 5,
          ac: 23,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(3, 2, "D8", magic_weapon_bonus(15) + ability_modifier(15), magic_weapon_bonus(15) + ability_modifier(15)+PROFICIENCY_MODIFIER_TABLE[15])],
            ranged: [],
            magic_ranged: []
          }
        },
        rogue: {
          con_bonus: 1,
          ac: 20,
          attacks: {
            melee: [Sim::MonsterDefinition.create_attack(1, 2, "D6", 0, ability_modifier(15)+PROFICIENCY_MODIFIER_TABLE[15]), 
              Sim::MonsterDefinition.create_attack(1, 9, "D6", magic_weapon_bonus(15) + ability_modifier(15), magic_weapon_bonus(15) + ability_modifier(15)+PROFICIENCY_MODIFIER_TABLE[15])],
            ranged: [],
            magic_ranged: []
          }
        },
        wizard: {
          con_bonus: 1,
          ac: 14,
          attacks: {
            melee: [],
            ranged: [],
            # Upcast lightning bolt, no save
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 10, "D6", 0, 100)]
          }
        },
        cleric: {
          con_bonus: 3,
          ac: 21,
          attacks: {
            melee: [],
            ranged: [],
            magic_ranged: [Sim::MonsterDefinition.create_attack(1, 3, "D8", 0, ability_modifier(15)+PROFICIENCY_MODIFIER_TABLE[15]), 
              Sim::MonsterDefinition.create_attack(1, 7, "D6", 0, 100)]
          }
        }
      }
    }
    player_stats.each_pair do |level, classes|
      if level >= 5
        classes.each_pair do |player_class, pc_data|
          next unless player_class == :wizard
          if pc_data[:attacks][:magic_aoe].blank?
            # Fireball, reduced from 8d6 to 6d6 to sim some saves for half damage
            pc_data[:attacks][:magic_aoe] = [Sim::MonsterDefinition.create_attack(1, 6, "D6", 0, 100)]
          end
        end
      end
    end
    player_stats
  end
end