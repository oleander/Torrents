require 'rest_client'
require 'nokogiri'
require 'torrents/container'

class Torrents < Container::Shared
  attr_accessor :page
  
  def initialize
    @torrents = []
    @url = {
      callback: lambda { |obj|
        obj.send(:inner_recent_url)
      },
      search: {
        value: ""
      }
    }
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
    @url[:callback].call(self).
      gsub('<SEARCH>', @url[:search][:value]).
      gsub('<PAGE>', self.inner_page)
  end
  
  # Makes this the {tracker} tracker
  def add(tracker)
    @tracker = tracker.to_s; self
  end
  
  def page(value)
    @page = value; self
  end
  
  def debugger(value)
    @debug = value; self
  end
  
  # Set the search value
  def search(value)
    @url.merge!(:callback => lambda { |obj|
      obj.send(:inner_search_url)
    }, :search => {:value => value}); self
  end
  
  def category(cat)
    @url.merge!(:callback => lambda { |obj|
      obj.send(:inner_category_url, cat)
    }); self
  end
  
  # If the user is trying to do some funky stuff to the data
  def method_missing(method, *args, &block)
    return self.inner_call($1.to_sym, args.first) if method =~ /^inner_(.+)$/
    super(method, args, block)
  end
  
  def self.method_missing(method, *args, &block)
    this = Torrents.new
    # Raises an exception if the site isn't in the trackers.yaml file
    raise Exception.new("The site #{method} does not exist") unless this.exists?(method)
    
    # Yes, I like return :)
    return this.add(method)
  end
  
  def results
    return @torrents if @torrents.any?
    self.inner_torrents(self.content).each do |tr|
      
      arguments = {
        details: self.inner_details(tr),
        torrent: self.inner_torrent(tr),
        title: self.inner_title(tr).to_s.strip
      }
      
      arguments.merge!(:debug => @debug) if @debug
      torrent = Container::Torrent.new(arguments)
      
      @torrents << torrent if torrent.valid?
    end
    
    return @torrents
  end
end
