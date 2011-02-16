require 'yaml'
require 'rest_client'
require 'nokogiri'
require 'torrents/torrent'

class Torrents < Container::Shared
  attr_accessor :page
  
  def initialize
    @trackers = YAML::load(File.read('lib/torrents/trackers.yaml'))
    @torrents = []
  end
  
  def content
    Nokogiri::HTML self.download(self.url)
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
    return self.inner_call($1, args) if method =~ /^inner_(.+)$/
      
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
        torrent = Container::Torrent.new({
          details: self.inner_details(tr), # self.append_url(tr.at_css(@current["css"]["details"]).attr('href')),
          torrent: self.inner_torrent(tr), #self.append_url(tr.to_s.match(/(http:\/\/.+\.torrent)/)[1]),
          title: self.inner_torrent(tr), #tr.at_css(@current["css"]["details"]).content,
          tracker: @current
        })
        
        @torrents << torrent if torrent.valid?
      end; return @torrents
    end
    
    # Appends the site url to the url if needed
    def append_url(data)
      data.match(/^http:\/\//) ? data : @current["url"] + data
    end
end
