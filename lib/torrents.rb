require 'yaml'
class Torrents
  attr_accessor :page
  
  def initialize
    @trackers = YAML::load(File.read('lib/torrents/trackers.yaml'))
  end
  
  # Set the default page
  def inner_page
    (@page ||= @current["start_page_index"]).to_s
  end
  
  def url
    puts self[:current]
    puts @current
    if @search_value
      pend = @current["search"].gsub('<SEARCH>', @search_value).gsub('<PAGE>', self.inner_page)
    else 
      pend = @current["recent"].gsub('<PAGE>', self.inner_page)
    end
    
    @current["url"] + pend
  end
  
  # Does the trackers exists in the trackers file?
  def exists?(site)
    ! @trackers[site.to_s].nil?
  end
  
  # Makes this the {tracker} tracker
  def add(tracker)
    @current = @trackers[tracker.to_s]
    return self
  end
  
  def page(value)
    @page = value
    return self
  end
  
  # Set the search value
  def search(value)
    @search_value = value
    return self
  end
  
  def self.method_missing(method, *args, &block)
    this = Torrents.new
    # Raises an exception if the site isn't in the trackers.yaml file
    raise Exception.new("The site #{method} does not exist") unless this.exists?(method)
    
    # Yes, I like return :)
    return this.add(method)
  end
end
