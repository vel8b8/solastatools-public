class Sim::MonsterDefinition
  attr_accessor :name, :hp, :total_hp, :attacks, :attack_def_refs, :ac, :legendary, :cr, :battle_decision, :monster_reference_definition, :internal_name

  def initialize(name, hp = 0, ac = 0, cr = 0, legendary = false, battle_decision = nil, monster_reference_definition = nil, internal_name = nil)
    raise StandardError, "Invalid empty monster name" if name.blank?
    @name = name
    @hp = hp
    @total_hp =hp
    @ac = ac
    @cr = cr
    @legendary = legendary.present? ? legendary : false
    @battle_decision = battle_decision
    @monster_reference_definition = monster_reference_definition
    @internal_name = internal_name
    # TODO magic_melee
    @attacks = {melee: [], ranged: [], magic_ranged: []}
    @attack_def_refs = {melee: [], ranged: [], magic_ranged: []}
  end

  def self.create_attack(iterations, dice_number, die_type, bonus_damage, to_hit_bonus)
    to_processed_attack = add_attack_effect("", iterations, dice_number, die_type, bonus_damage)
    to_processed_attack = add_to_hit(to_processed_attack, to_hit_bonus)
    to_processed_attack
  end

  def self.add_attack_effect(to_processed_attack, iterations, dice_number, die_type, bonus_damage)
    raise ArgumentError, "Invalid parameter: iterations=#{iterations}" if iterations <= 0
    raise ArgumentError, "Invalid parameter: dice_number=#{dice_number}" if dice_number <= 0
    raise ArgumentError, "Invalid parameter: die_type" if die_type.blank? 
    to_processed_attack = "" if to_processed_attack.nil?
    to_processed_attack += ", " if to_processed_attack.present?
    bonus_damage = 0 if bonus_damage.blank?
    to_processed_attack += "#{iterations} x #{dice_number}#{die_type}+#{bonus_damage}"
    to_processed_attack
  end

  def self.add_to_hit(to_processed_attack, to_hit_bonus)
    to_hit_bonus = 0 if to_hit_bonus.blank?
    to_processed_attack += ", to_hit + #{to_hit_bonus}"
  end
end