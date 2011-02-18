require 'yaml'
require 'rest_client'
require 'nokogiri'
require 'torrents/torrent'

class Torrents < Container::Shared
  attr_accessor :page
  
  def initialize
    @trackers = YAML::load(File.read('./lib/torrents/trackers.yaml'))
    @torrents = []
    @search_type = :inner_recent_url
    @search_value = ""
  end
  
  def results
    self.torrents
  end
  
  def content
    Nokogiri::HTML self.download(self.url)
  end
  
  # Set the default page
  def inner_page
    (@page ||= @current["start_page_index"]).to_s
  end

  def url
    @current["url"] + self.send(@search_type).gsub('<SEARCH>', @search_value).gsub('<PAGE>', self.inner_page)
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
  
  def debugger(value)
    Container::Shared.debugger(@debug = value)
    return self
  end
  
  # Set the search value
  def search(value)
    @search_value = value
    @search_type = :inner_search_url
    return self
  end
  
  # If the user is trying to do some funky stuff to the data
  def method_missing(method, *args, &block)
    return self.inner_call($1, args.first) if method =~ /^inner_(.+)$/
    super(method, args, block)
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
      return @torrents if @torrents.any?
      self.inner_torrents(self.content).each do |tr|
        torrent = Container::Torrent.new({
          details: self.inner_details(tr),
          torrent: self.inner_torrent(tr),
          title: self.inner_torrent(tr),
          tracker: @current,
          debug: @debug
        })
        
        @torrents << torrent if torrent.valid?
      end; return @torrents
    end
end
