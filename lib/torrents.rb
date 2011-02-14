require 'yaml'
class Torrents
  def initialize
    @trackers = YAML::load(File.read('lib/torrents/trackers.yaml'))
  end
  
  # Does the trackers exists in the trackers file?
  def exists?(site)
    ! @trackers[site.to_s].nil?
  end

  def self.method_missing(method, *args, &block) 
    this = Torrents.new
    # Raises an exception if the site isn't in the trackers.yaml file
    raise Exception.new("The site #{method} does not exist") unless this.exists?(method)
  end
end
