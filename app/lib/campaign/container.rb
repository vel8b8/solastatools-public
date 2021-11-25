class Campaign::Container
  attr_accessor :uuid, :title, :author, :author_version, :locations

  def initialize
    @locations = []
  end

  # def initialize(title, author, author_version, locations)
  #   @title = title
  #   @author = author
  #   @author_version = author_version
  #   @locations = locations
  # end
end