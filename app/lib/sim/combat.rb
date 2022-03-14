class Sim::Combat
  attr_reader :combat_log

  def initialize
    @combat_log = []
    # "2 x 1D8+3, to_hit + 5"
    # ref MonsterDefinition
    @to_hit_regex = Regexp.new(/to_hit *\+ *(\d+)/)
    @damage_regex = Regexp.new(/(\d+) *x *(\d+)D(\d+) *\+ *(\d+)/)
    @special_attack_uses = { magic_aoe: {} }
    @@missing_die_sides ||= {}
  end

  def attack_damage(from_monster, to_monster, dice, attack_type, which_attack)
    components = @damage_regex.match(which_attack)
    iterations = components[1].to_i
    number_of_dice = components[2].to_i
    die_sides = components[3]&.to_i
    if die_sides.blank? || die_sides == 0
      # WARN: Missing dieType in attack definition filename=Attack_FlyingSnake_Bite.474c266753b8ee0429bcb41b2ecf0d2b.json
      Rails.logger.error("Sim::Combat Missing die_sides in attack_damage. from_monster.name=#{from_monster.name} to_monster.name=#{to_monster.name} which_attack=#{which_attack}") unless @@missing_die_sides["#{from_monster.name}"]
      @@missing_die_sides["#{from_monster.name}"] = true
      return 0
    end
    damage_bonus = components[4].to_i
    damage = (0...number_of_dice).inject(0) { |sum, _| sum + dice.roll(die_sides, iterations) }
    @combat_log << "from_monster.name=#{from_monster.name} target_name=#{to_monster.name}  attack_type=#{attack_type} damage=#{damage + iterations * damage_bonus} damage_breakdown=#{damage}+#{iterations*damage_bonus}"
    damage + iterations * damage_bonus
  end

  def roll_to_hit(from_monster, to_monster, dice, attack_type, which_attack, target_ac)
    to_hit = @to_hit_regex.match(which_attack)
    to_hit = to_hit.present? && to_hit[1].present? ? to_hit[1].to_i : 0
    base_roll = dice.roll(20)
    hit_type = :miss
    if base_roll == 20
      hit_type = :critical 
    elsif base_roll + to_hit >= target_ac
      hit_type = :hit
    end
    @combat_log << "from_monster.name=#{from_monster.name} target_name=#{to_monster.name} attack_type=#{attack_type} hit_type=#{hit_type} modified_roll=#{base_roll}+#{to_hit} vs #{target_ac}"
    hit_type
  end

  def magic_aoe_available?(from_monster)
    return false unless @special_attack_uses.key?(:magic_aoe)
    return true unless @special_attack_uses[:magic_aoe].key?(from_monster)
    # Cast more fireballs per combat encounter at higher caster levels
    if from_monster.cr < 5
      aoe_limit = 0
    elsif from_monster.cr < 8
      aoe_limit = 1
    elsif from_monster.cr < 12
      aoe_limit = 2
    elsif from_monster.cr < 20
      aoe_limit = 3
    end
    @special_attack_uses[:magic_aoe][from_monster] < aoe_limit
  end

  def track_cast_aoe(from_monster, attack_type)
    @special_attack_uses[attack_type][from_monster] ||= 0
    @special_attack_uses[attack_type][from_monster] += 1
  end
end