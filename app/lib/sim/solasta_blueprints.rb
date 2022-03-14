require 'zip'
class Sim::SolastaBlueprints
  def self.solasta_monster_definitions
    @@monster_definitions ||= Sim::SolastaBlueprints.new.load_monster_definitions
  end

  # from scripts/extract_monster_blueprints.rb
  def load_monster_definitions
    blueprints_zip_path = Rails.root.join('config', 'solastadata', 'blueprints.marshaled.zip')
    blueprints_tmp_path = Rails.root.join('tmp', 'blueprints.marshaled')
    Rails.logger.info("SolastaBlueprints loading. blueprints_zip_path=#{blueprints_zip_path} blueprints_tmp_path=#{blueprints_tmp_path}")
    blueprints_tmp_path.delete if blueprints_tmp_path.exist?
    Zip::File.open(blueprints_zip_path.to_s) do |zipfile|
      zipfile.each do |entry|
        entry.extract(blueprints_tmp_path.to_s)
      end
    end
    File.open(blueprints_tmp_path.to_s, 'r') do |file|
      encoded = file.read
      marshaled = Base64.decode64(encoded)
      return Marshal.load(marshaled)
    end
  end

  # processed_monster_defs: hash with keys monster reference name e.g. 'Generic_Darkweaver' and value Sim::MonsterDefinition
  def serialize_monster_definitions(processed_monster_defs)
    marshaled = Marshal.dump(processed_monster_defs)
    Base64.encode64(marshaled)
  end
end