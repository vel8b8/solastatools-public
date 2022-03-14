class Sim::FightClub
  def initialize(ai_type=:normal, total_combat_iterations=33)
    @club_id = SecureRandom.uuid[0...8]
    @rogue_re = /(_rogue|_darkweaver)/i
    @ai_type = ai_type
    @total_combat_iterations = total_combat_iterations
  end

  def self.deep_copy(object)
    Marshal.load(Marshal.dump(object))
  end

  def self.create_monster_party(monster_defs, monster_names)
    monster_names.inject([]) { |members, name| members << Sim::FightClub.deep_copy(monster_defs[name]) }
  end

  def select_monsters(monster_party)
    # Every monster still alive
    selected_monsters = monster_party.select { |member| member.hp > 0 }
    return selected_monsters if selected_monsters.blank?
    alternate = nil
    # Choose lowest AC target first
    monster_party.each do |member|
      next unless member.hp > 0
      if @ai_type == :deadly
        # Deadlier + Merciless AI, target the poor low AC casters
        alternate = member if member.ac < selected_monsters[0].ac
      else
        # Normal melee AI, target the "meaty" tank
        alternate = member if member.total_hp > selected_monsters[0].total_hp
      end
    end
    if alternate.present?
      selected_monsters.delete(alternate)
      selected_monsters.insert(0, alternate)
    end
    selected_monsters
  end

  def perform_attack!(combat, attack_type, which_attack, from_monster, to_monster, damage_multiplier)
    dice = Sim::Dice.new
    hit_type = combat.roll_to_hit(from_monster, to_monster, dice, attack_type, which_attack, to_monster.ac)
    return false if hit_type != :hit && hit_type != :critical
    multiplier = hit_type == :critical ? 2 : 1
    multiplier *= damage_multiplier.to_f
    damage = combat.attack_damage(from_monster, to_monster, dice, attack_type, which_attack)
    adjusted_damage = damage * multiplier
    combat.combat_log << "name=#{to_monster.name} adjusted_damage_received=#{adjusted_damage}" if adjusted_damage != damage
    to_monster.hp -= adjusted_damage
    true
  end

  def calc_health_remaining_ratio(full_health_player_party, wounded_player_party)
    total_health = full_health_player_party.inject(0) { |sum, member| sum + member.hp }
    remaining_health = wounded_player_party.inject(0) { |sum, member| sum + member.hp }
    remaining_health / total_health.to_f
  end

  def select_attack_type(member, target_mobs, sim_combat)
    if member.attacks[:magic_aoe].present? && target_mobs.size > 2 && sim_combat.magic_aoe_available?(member)
      return :magic_aoe
    end
    [member.battle_decision, :magic_ranged, :melee, :ranged].each do |attack_type|
      return attack_type if member.attacks[attack_type].present?
    end
    nil
  end

  def rogue?(target_mob)
    @rogue_re.match(target_mob.name)
  end

  def perform_combat_turn(from_member, to_party, sim_combat)
    deaths = 0
    was_hit_once = {}
    all_target_mobs = select_monsters(to_party)
    return { victory: true, deaths: 0 } if all_target_mobs.blank?
    # TODO attack priority
    attack_type = select_attack_type(from_member, all_target_mobs, sim_combat)
    from_member.attacks[attack_type].each do |which_attack|
      if attack_type == :magic_aoe
        sim_combat.track_cast_aoe(from_member, attack_type)
      else
        all_target_mobs = [all_target_mobs.first]
      end
      all_target_mobs.each do |target_mob|
        # TODO damage type resistances
        damage_multiplier = 1.0
        damage_reduction_type = nil
        # TODO use correct uncanny dodge rules
        if !was_hit_once[target_mob] && target_mob.cr >= 5 && rogue?(target_mob)
          damage_multiplier = 0.5
          damage_reduction_type = :uncanny_dodge
        elsif target_mob.legendary && [:magic_ranged, :magic_aoe].include?(attack_type)
          damage_multiplier = 0.5
          damage_reduction_type = :legendary_resistance
        end
        # TODO aoe spells (fireball) should only roll attack damage once for all targets, rather than roll for each target
        hit = perform_attack!(sim_combat, attack_type, which_attack, from_member, target_mob, damage_multiplier)
        if hit
          sim_combat.combat_log << "name=#{target_mob.name} damage_reduction=#{damage_reduction_type}" if damage_reduction_type.present?
          was_hit_once[target_mob] = true
        end
        if target_mob.hp <= 0
          sim_combat.combat_log << "name=#{target_mob.name} died"
          deaths += 1
          all_target_mobs = select_monsters(to_party)
        end
        break if all_target_mobs.blank?
      end
      break if all_target_mobs.blank?
    end
    {
      victory: all_target_mobs.blank?,
      deaths: deaths
    }
  end

  def actors_by_initiative(player_party, monster_party)
    initiatives = []
    dice = Sim::Dice.new
    actors = player_party.map { |member| { member: member, opposing_party: monster_party } }
    actors.concat(monster_party.map { |member| { member: member, opposing_party: player_party } })
    actors.each do |actor_data|
      roll = dice.roll(20)
      # TODO use dexterity ability modifier
      roll += rogue?(actor_data[:member]) ? 4 : 0
      initiatives << { initiative: roll, member: actor_data[:member], opposing_party: actor_data[:opposing_party] }
    end
    initiatives.sort_by { |data| -1 * data[:initiative] }
  end

  def fight(player_party, monster_party)
    full_health_player_party = Sim::FightClub.deep_copy(player_party)
    player_party = Sim::FightClub.deep_copy(player_party)
    monster_party = Sim::FightClub.deep_copy(monster_party)
    combat = Sim::Combat.new
    combat.combat_log << "Combat begins!"
    round_count = 1
    whose_victory = nil
    character_deaths = 0
    actors = actors_by_initiative(player_party, monster_party)
    combat.combat_log << "Initiative order: " +  actors.map { |d| "(#{d[:initiative]}) #{d[:member].name}"}.join(', ')
    while round_count < 30 do
      actors.each do |actor_data|
        next if actor_data[:member].hp <= 0
        turn_results = perform_combat_turn(actor_data[:member], actor_data[:opposing_party], combat)
        if turn_results[:deaths] > 0 && actor_data[:opposing_party] == player_party
          character_deaths += turn_results[:deaths]
        end
        if turn_results[:victory]
          if actor_data[:opposing_party] == monster_party
            combat.combat_log << "Player victory"
            whose_victory = :player
          else
            combat.combat_log <<  "Player tpk'd"
            whose_victory = :monster
          end
          break
        end
      end
      break if whose_victory.present?
      round_count += 1
    end
    health_remaining_ratio = calc_health_remaining_ratio(full_health_player_party, player_party)
    player_victory = whose_victory == :player
    combat.combat_log << "Combat ended in rounds=#{round_count} player_victory=#{player_victory} health_remaining_ratio=#{health_remaining_ratio.round(2)}"
    { 
      player_victory: player_victory,
      health_remaining_ratio: health_remaining_ratio,
      character_deaths: character_deaths,
      combat_log: combat.combat_log
    }
  end

  def create_combat_stats(player_level=nil, player_party=nil, monster_party=nil)
    combat_stats = { 
      player_level: player_level,
      wins: 0, 
      fights: 0, 
      radicand: 1.0, 
      total_character_deaths: 0,
      player_party: player_party
    }
  end

  def combat_iterations(player_level, player_party, monster_party, include_combat_log_sample)
    combat_results = []
    @total_combat_iterations.times { combat_results << fight(player_party, monster_party) }
    combat_stats = create_combat_stats(player_level, player_party, monster_party)
    combat_stats[:fights] = combat_results.size
    combat_results.each do |result|
      combat_stats[:wins] += 1 if result[:player_victory]
      combat_stats[:total_character_deaths] += result[:character_deaths]
      hrr = result[:health_remaining_ratio] > 0 ? result[:health_remaining_ratio] : 0.0
      combat_stats[:radicand] *= 1.0 + hrr
    end
    combat_stats[:combat_log_sample] = include_combat_log_sample ? combat_results.first[:combat_log] : nil
    # geometric average return of health remaining
    combat_stats[:health_remaining_geo_avg_return] = combat_stats[:radicand] ** (1.0/combat_results.size) - 1.0
    combat_stats[:win_rate] = combat_stats[:wins] / combat_results.size.to_f
    combat_stats[:average_character_deaths] = combat_stats[:total_character_deaths] / combat_results.size.to_f
    combat_stats
  end

  def death_tolerance(player_level)
    # We allow up to X characters to be downed (nearly die) because our simulated combat does not simulate protective abilities, player positioning, heals, etc. that would prevent it. In actual play, it's unlikely the player would be downed with the below thesholds.
    # Allow less character death at lower levels
    tolerance = 2.2
    case player_level
    when 1
      tolerance = 0.15
    when 2
      tolerance = 0.25
    when 3
      tolerance = 0.5
    when 4
      tolerance = 1.0
    when 5
      tolerance = 1.65
    end
    tolerance
  end

  # Debug show health thresholds at each win rate and level:
  # [0.95, 0.85, 0.7].each { |win_rate| pp (1..12).map { |level| health_remaining_threshold(level, win_rate, 0.75).round(2) } }
  def health_remaining_threshold(player_level, win_rate, floor_win_rate)
    floor_health = 0.5 # at level 12 and up
    ceil_health = 0.8 # at level 1
    threshold = ceil_health - ((ceil_health - floor_health)/(12.0-1))*(player_level-1)
    return threshold if win_rate <= floor_win_rate
    threshold = (1 - ((win_rate-floor_win_rate)*0.5))*threshold
    threshold
  end

  def calculate_xp_adjustment(player_level, monster_party)
    cr_based_xp = 0
    monster_party.each do |monster|
      cr_based_xp = SrdCrXp.xp_for_cr(monster.cr)
    end
    ed_based_xp = SrdCrXp.xp_for_cr(player_level)
    ((ed_based_xp - cr_based_xp) / 4.0).to_i
  end

  # monster_party: a list of Sim::MonsterDefinition
  def estimated_difficulty(monster_party, include_combat_log_sample=true)
    Rails.logger.info("FightClub starting combat simulation. club_id=#{@club_id} monster_party_size=#{monster_party.size}")
    party_factory = Sim::PlayerPartyFactory.new
    accumulated_combat_stats = []
    player_status = :tpk
    party_depletion = 1.0
    party_factory.available_player_levels.sort.each do |player_level|
      player_party = party_factory.create_player_party(player_level)
      combat_stats = combat_iterations(player_level, player_party, monster_party, include_combat_log_sample)
      accumulated_combat_stats << combat_stats
      
      if combat_stats[:average_character_deaths] < death_tolerance(player_level)
        all_win_rates = [0.95, 0.85, 0.75]
        floor_win_rate = all_win_rates.last
        all_win_rates.each do |win_rate|
          if combat_stats[:win_rate] >= win_rate \
            && combat_stats[:health_remaining_geo_avg_return] >= health_remaining_threshold(player_level, win_rate, floor_win_rate)
            party_depletion = (1.0 - combat_stats[:health_remaining_geo_avg_return]).round(8)
            player_status = :win
            break
          end
        end
        break if player_status == :win
      end
    end
    player_level = accumulated_combat_stats.last[:player_level]
    xp_adjustment = calculate_xp_adjustment(player_level, monster_party)
    Rails.logger.info("FightClub concluded. Player status=#{player_status} club_id=#{@club_id} player_level=#{player_level} monster_party_size=#{monster_party.size}")
    return { player_status: player_status, player_level: player_level, party_depletion: party_depletion, xp_adjustment: xp_adjustment, fight_club_id: @club_id, stats_list: accumulated_combat_stats, monster_party: monster_party }
  end
end