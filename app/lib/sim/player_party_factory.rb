class Sim::PlayerPartyFactory
  HIT_DICE_TABLE = {
    wizard: 6,
    cleric: 8,
    rogue: 8,
    fighter: 10
  }
  
  def initialize
    @level_stats_table = Sim::PlayerLevelStats.new.create_player_level_stats
  end

  def available_player_levels
    @level_stats_table.keys
  end

  def random_name
    SecureRandom.base64.gsub(/[\+=\/0-9]+/,"")[0...6].downcase.capitalize
  end

  def create_character(class_type, level)
    class_stats = @level_stats_table[level].present? ? @level_stats_table[level][class_type] : nil
    raise StandardError, "Missing stats for class_type=#{class_type} level=#{level}" if class_stats.blank?

    dice = Sim::Dice.new
    # generously max hp at level 1
    hp = HIT_DICE_TABLE[class_type] + class_stats[:con_bonus]
    hp += (1...level).inject(0) { |sum, _| sum + class_stats[:con_bonus] + dice.roll(HIT_DICE_TABLE[class_type]) }
    character = Sim::MonsterDefinition.new("PC_#{class_type}_L#{level}_#{random_name}", hp, class_stats[:ac], level, "player_character")
    character.attacks = class_stats[:attacks].clone
    character
  end

  def create_player_party(party_level)
    raise ArgumentError, "Invalid level" if party_level < 1 || party_level > 20
    raise ArgumentError, "Missing level data for level=#{party_level}" unless @level_stats_table.has_key?(party_level)
    [
      create_character(:fighter, party_level), 
      create_character(:rogue, party_level),
      create_character(:cleric, party_level),
      create_character(:wizard, party_level),
    ]
  end
end