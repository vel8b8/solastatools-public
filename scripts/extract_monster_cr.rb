require 'json'
# For use with SolastaMods/SolastaBlueprints/MonsterDefinition json files (extracted from Solasta resources.assets)
class ExtractMonsterData
  def load(monster_definition_directory)
    monsters = {}
    Dir.children(monster_definition_directory).each do |filename|
      absolute_path = File.join(monster_definition_directory, filename)
      monster_data = {}
      File.open(absolute_path, 'r') do |file|
        monster_data = JSON.parse(file.read)
      end
      monsters[monster_data['name']] = { cr: monster_data['challengeRating'] }
    end
    monsters
  end

  def self.run(monster_definition_directory)
    monsters = ExtractMonsterData.new.load(monster_definition_directory)
    puts monsters.to_json
  end
end

if __FILE__ == $0
  ::Rails.logger = ActiveSupport::Logger.new(STDOUT) if Rails.env == 'development'
  ExtractMonsterData.run(ARGV[0])
end
