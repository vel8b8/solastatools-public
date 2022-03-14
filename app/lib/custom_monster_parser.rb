class CustomMonsterParser
  # monster_definitions: reference definitions for official Solasta monsters, loaded from Sim::SolastaBlueprints
  def initialize(reference_monster_definitions)
    @reference_monster_definitions = reference_monster_definitions
  end

  # custom_monster_data: hash key: internalName, value: campaign json "userMonsters" section array element as ruby hash
  # return: array of Sim::MonsterDefinition
  def create_monster_definitions(custom_monster_data)
    monster_definitions = []
    custom_monster_data.each_pair do |internal_name, monster_data|
      monster_data = monster_data[:monster_details]
      # (name, hp = 0, ac = 0, cr = 0, legendary = false, battle_decision = nil)
      refdef = monster_data['referenceDefinition']
      unless @reference_monster_definitions.has_key?(refdef)
        Rails.logger.error("CustomMonsterParser missing monster reference definition. internal_name=#{internal_name} refdef=#{refdef} reference_monster_definitions_size=#{@reference_monster_definitions.size}")
        next
      end
      name = "#{monster_data['title']} (#{refdef})"
      ref_monster = @reference_monster_definitions[refdef]
      new_monster_def = Sim::MonsterDefinition.new(name, monster_data['hitPoints'], monster_data['armorClass'], ref_monster.cr, ref_monster.legendary, ref_monster.battle_decision, refdef, monster_data['internalName'])
      process_attacks(monster_data, new_monster_def, ref_monster)
      monster_definitions << new_monster_def
    end
    monster_definitions
  end

  private

  def find_attack_type(attack_def_name, ref_monster)
    ref_monster.attack_def_refs.keys.each do |attack_type|
      found = ref_monster.attack_def_refs[attack_type].find { |adr| adr == attack_def_name }
      return attack_type if found.present?
    end
    :melee
  end

  def process_attacks(monster_data, new_monster_def, ref_monster)
    (0...10).each do |attack_index|
      attack_key = "attack#{attack_index}"
      if monster_data.has_key?(attack_key)
        an_attack = monster_data[attack_key]
        attack_def_name = an_attack['monsterAttackDefinitionName']
        attack_type = find_attack_type(attack_def_name, ref_monster)
        processed_attack = ''
        an_attack = monster_data[attack_key]
        if an_attack['effectForms'].blank?
          Rails.logger.warn("CustomMonsterParser missing effectForms in monster_data. title=#{monster_data['title']} attack_key=#{attack_key}")
          next
        end
        skip_attack = false
        an_attack['effectForms'].each do |effect_form|
          die_type = "D#{effect_form['dieType']}"
          if an_attack['iterations'] <= 0
            Rails.logger.warn("CustomMonsterParser ignored attack due to invalid iterations. title=#{monster_data['title']} attack_key=#{attack_key} iterations=#{an_attack['iterations']}")
            skip_attack = true
            break
          end
          processed_attack = Sim::MonsterDefinition.add_attack_effect(processed_attack, an_attack['iterations'], effect_form['diceNumber'], die_type, effect_form['bonusDamage'])
        end
        next if skip_attack
        processed_attack = Sim::MonsterDefinition.add_to_hit(processed_attack, an_attack['toHitBonus'])
        new_monster_def.attacks[attack_type] << processed_attack
        new_monster_def.attack_def_refs[attack_type] << attack_def_name
      end
    end
  end
end