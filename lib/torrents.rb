require 'yaml'
require 'rest_client'
require 'nokogiri'
require 'torrents/torrent'

class Torrents
  attr_accessor :page
  
  def initialize
    @trackers = YAML::load(File.read('lib/torrents/trackers.yaml'))
    @torrents = []
  end
  
  def download
    RestClient.get self.url, {:timeout => 10}
  end
  
  def content
    Nokogiri::HTML self.download
  end
  
  # Set the default page
  def inner_page
    (@page ||= @current["start_page_index"]).to_s
  end
  
  def url
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
  
  # If the user is trying to do some funky stuff to the data
  def method_missing(method, *args, &block)
    super(method, args, block) unless [].methods.include? method
    
    self.torrents.send(method)
  end
  
  def self.method_missing(method, *args, &block)
    this = Torrents.new
    # Raises an exception if the site isn't in the trackers.yaml file
    raise Exception.new("The site #{method} does not exist") unless this.exists?(method)
    
    # Yes, I like return :)
    return this.add(method)
  end
  
  protected
    def torrents
      self.content.css(@current["css"]["tr"]).each do |tr|
        @torrents << Container::Torrent.new({
          details: @current["url"] + tr.at_css(@current["css"]["details"]).attr('href')
        })
      end
      
      return @torrents
    end
end
