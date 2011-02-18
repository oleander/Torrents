require 'rest_client'
require 'nokogiri'
require 'torrents/torrent'

class Torrents < Container::Shared
  attr_accessor :page
  
  def initialize
    @torrents = []
    @search = {
      type: :inner_recent_url,
      value: ""
    }
  end
  
  def results
    self.torrents
  end
  
  def exists?(tracker)
    File.exists?(File.dirname(File.expand_path( __FILE__)) + "/torrents/trackers/" + tracker.to_s + ".rb")
  end
  
  def content
    Nokogiri::HTML self.download(self.url)
  end
  
  # Set the default page
  def inner_page
    (@page ||= self.inner_start_page_index).to_s
  end

  def url
    self.send(@search[:type]).gsub('<SEARCH>', @search[:value]).gsub('<PAGE>', self.inner_page)
  end
  
  # Makes this the {tracker} tracker
  def add(tracker)
    @tracker = tracker.to_s
    return self
  end
  
  def page(value)
    @page = value
    return self
  end
  
  def debugger(value)
    @debug = value
    return self
  end
  
  # Set the search value
  def search(value)
    @search.merge!(:type => :inner_search_url, :value => value)
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
          debug: @debug
        })
        
        @torrents << torrent if torrent.valid?
      end; return @torrents
    end
end
