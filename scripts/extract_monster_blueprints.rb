require 'json'
require 'pp'

# For use with SolastaMods/SolastaBlueprints/MonsterDefinition json files (extracted from Solasta resources.assets)
class ExtractMonsterBlueprints
  def load_files(from_path)
    monsters = {}
    Dir.children(from_path).each do |filename|
      absolute_path = File.join(from_path, filename)
      File.open(absolute_path, 'r') do |file|
        begin
          blueprint = JSON.parse(file.read)
        rescue StandardError => err
          STDERR.puts "ERROR: Failed to load filename=#{absolute_path} error=#{err}"
          next
        end
        should_add = true
        if block_given?
          should_add = yield(blueprint)
        end
        monsters[filename] = blueprint if should_add
      end
    end
    monsters
  end

  def extract_attack_type(attack_definition)
    return :ranged if attack_definition['proximity'] == 'Range'
    :melee
  end

  def extract_attack_def_ref(monster_attack_definition)
    # "Definition:Attack_Darkweaver_LightCrossbow:286e76712de29a64889afefb3a564d48"
    # ->
    # Attack_Darkweaver_LightCrossbow
    atkdef = monster_attack_definition.sub(/^Definition:/, '')
    atkdef.sub(/:.*/, '')
    atkdef.sub(/\..*/, '')
  end

  def extract_battle_decision(default_battle_decision_package)
    case default_battle_decision_package
    # "defaultBattleDecisionPackage": "Definition:DefaultSupportCasterWithBackupAttacksDecisions:f99448e8f4c2d9d478837c543e3e205f",
    when /DefaultSupportCaster/
      # Archmage, Acolyte, Evil Priest
      :magic_ranged
    when /CasterCombat/
      # Shaman
      :magic_ranged
    when /ClericCombat/
      # High Priest
      :magic_ranged
    when /Necromancer/
      :magic_ranged
    when /DefaultRange/
      :ranged
    when /DragonCombat/
      :melee
    when /DefaultMelee/
      :melee
    else
      :melee
    end
  end

  def run(blueprint_directory, output_pretty = false)
    raise StandardError, "No blueprint directory specified." if blueprint_directory.blank?
    blueprints = ExtractMonsterBlueprints.new
    atk_def_path = File.join(blueprint_directory, 'MonsterAttackDefinition')
    attack_definitions = blueprints.load_files(atk_def_path)
    mon_path = File.join(blueprint_directory, 'MonsterDefinition')
    monster_def_data = blueprints.load_files(mon_path) { |blueprint| blueprint['dungeonMakerPresence'] == 'Monster' }
    #STDERR.puts "INFO: Loaded attack_definitions=#{attack_definitions.size} monster_definitions=#{monster_def_data.size}"
    processed_monster_defs = {}
    monster_def_data.each_pair do |filename, monster|
      name = filename.split(/\./)[0]
      battle_decision = extract_battle_decision(monster['defaultBattleDecisionPackage'])
      new_monster_def = Sim::MonsterDefinition.new(name, monster['standardHitPoints'], monster['armorClass'], monster['challengeRating'], monster['legendaryCreature'], battle_decision, name, name)
      monster['attackIterations'].each do |attack_iteration|
        atkdef_filename = attack_iteration['monsterAttackDefinition']
        iterations = attack_iteration['number']
        # Definition:Attack_Veteran_Longsword:2831e20104ee0f74498b456b839ec080
        atkdef_filename.sub!(/^Definition:/, '')
        atkdef_filename.gsub!(/:/, '.')
        atkdef_filename = "#{atkdef_filename}.json"
        if attack_definitions[atkdef_filename].blank?
          STDERR.puts "WARN: Failed to find attack definition file=#{atkdef_filename} for monster_filename=#{filename}"
          next
        end

        atk_def = attack_definitions[atkdef_filename]
        attack_type = extract_attack_type(atk_def)
        processed_attack = ''
        atk_def['effectDescription']['effectForms'].each do |effect_form|
          # TODO conditionForm, damage type
          damage_form = effect_form['damageForm']
          die_type = "D6"
          if damage_form['dieType'].blank?
            STDERR.puts "WARN: Missing dieType in attack definition filename=#{atkdef_filename}"
          else
            die_type = damage_form['dieType']
          end
          begin
            processed_attack = Sim::MonsterDefinition.add_attack_effect(processed_attack, iterations, damage_form['diceNumber'], die_type, damage_form['bonusDamage'])
          rescue StandardError => err
            STDERR.puts "WARN: Failed to process attack definition filename=#{atkdef_filename}"
            raise
          end
        end
        processed_attack = Sim::MonsterDefinition.add_to_hit(processed_attack, atk_def['toHitBonus'])
        new_monster_def.attacks[attack_type] << processed_attack
        new_monster_def.attack_def_refs[attack_type] << extract_attack_def_ref(attack_iteration['monsterAttackDefinition'])
      end
      # TODO add to attack_type :magic_ranged,  "features": ["Definition:AdditionalDamage_OrcGrimblade_SneakAttack:19c3904ba11a0424daa775db15097952"] from FeatureDefinitionAdditionalDamage AdditionalDamage_OrcGrimblade_SneakAttack.19c3904ba11a0424daa775db15097952.json
      processed_monster_defs[name] = new_monster_def
    end
    if output_pretty
      pp(processed_monster_defs)
    else
      puts Sim::SolastaBlueprints.new.serialize_monster_definitions(processed_monster_defs)
    end
    processed_monster_defs
  end
end

if __FILE__ == $0
  pretty = ARGV[1] == '--pretty'
  ::Rails.logger = ActiveSupport::Logger.new(STDOUT) if Rails.env == 'development' if pretty
  ExtractMonsterBlueprints.new.run(ARGV[0], pretty)
end
