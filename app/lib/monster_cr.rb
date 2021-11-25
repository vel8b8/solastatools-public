class MonsterCr
  def self.find_cr(creature)
    @@solasta_cr_data ||= load_solasta_cr_json
    @@solasta_cr_data[creature].present? ? @@solasta_cr_data[creature]['cr'] : nil
  end

  def self.load_solasta_cr_json
    monster_json_filename = Rails.root.join('config', 'solastadata', 'monster_crs.json')
    File.open(monster_json_filename, 'r') do |file|
      return JSON.parse(file.read)
    end
  end
end