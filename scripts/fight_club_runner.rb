class FightClubRunner
  def estimated_cr_runner(monster_names)
    raise ArgumentError if monster_names.blank?
    monster_defs = Sim::SolastaBlueprints.solasta_monster_definitions
    monster_party = Sim::FightClub.create_monster_party(monster_defs, monster_names)
    fight_club = Sim::FightClub.new
    result = fight_club.estimated_difficulty(monster_party)
    accumulated_combat_stats = result[:stats_list]
    accumulated_combat_stats.each do |combat_stats|
      player_level = combat_stats[:player_level]
      if player_level == 1
        puts "__________ Monsters ___________________"
        pp monster_party
      end
      puts "__________ Player _____________________"
      pp combat_stats[:player_party]
      if player_level == accumulated_combat_stats.last[:player_level]
        puts "__________ Combat Log Sample __________"
        pp combat_stats[:combat_log_sample]
      end
      puts "__________ Combat Stats __________"
      pp combat_stats.except(:combat_log_sample, :player_party, :monster_party)
    end
    return result
  end

  def run_once(monster_names)
    if monster_names.blank?
      # monster_names = %w[SRD_Veteran Young_GreenDragon CrimsonSpider GreenDragon_MasterOfConjuration Generic_Warlord CrimsonSpiderling]
      monster_names = %w[Generic_Darkweaver]
    end
    result = estimated_cr_runner(monster_names)
    estimated_difficulty = result[:player_status] == :tpk ? '>' : ''
    estimated_difficulty += result[:player_level].to_s
    puts "Estimated Encounter Difficulty ED:\t#{estimated_difficulty}\tMonsters:\t#{monster_names}"
    result
  end

  def run(monster_names)
    if monster_names.present? && monster_names[0] == '--all'
      monster_defs = Sim::SolastaBlueprints.solasta_monster_definitions
      monster_defs.map { |kv| kv[0] }.each do |mon_name|
        run_once([mon_name])
      end
    else
      run_once(monster_names)
    end
  end
end

if __FILE__ == $0
  ::Rails.logger = ActiveSupport::Logger.new(STDOUT) if Rails.env == 'development'
  FightClubRunner.new.run(ARGV)
end