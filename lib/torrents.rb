$:.push File.expand_path("../../lib/torrents", __FILE__)
$:.push File.expand_path("../../lib/torrents/trackers", __FILE__)

require 'rest_client'
require 'nokogiri'
require 'torrents/container'

class Torrents < Container::Shared
  attr_accessor :page
  
  def initialize
    @torrents = []
    @errors   = []
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
    @content ||= Nokogiri::HTML(self.download(self.url))
  end
  
  # Set the default page
  def inner_page
    ((@page ||= 1) - 1 + self.inner_start_page_index).to_s
  end

  def url
    @url[:callback].call(self).
      gsub('<SEARCH>', @url[:search][:value]).
      gsub('<PAGE>', self.inner_page)
  end
  
  def step
    @step = true; self
  end
  
  # Makes this the {tracker} tracker
  def add(tracker)
    @tracker = tracker.to_s; self
  end
  
  def page(value)
    @page = value
    raise ArgumentError.new("To low page value, remember that the first page has the value 1") if self.inner_page.to_i < 0
    self
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
  
  def cookies(args)
    @cookies = args; self
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
  
  # Returns a Container::Torrent object
  # {details} (String) The details url for the torrent
  def find_by_details(details)
    self.create_torrent({
      details: details,
      tracker: @tracker
    })
  end
  
  # Creates a torrent based on the ingoing arguments
  # Is used by {find_by_details} and the {results} method
  # Returns a Container::Torrent object
  # {arguments} (Hash) The params to the Torrent constructor
  # The debugger and cookie param is passed by default
  def create_torrent(arguments)
    arguments.merge!(:debug => @debug) if @debug
    arguments.merge!(:cookies => @cookies) if @cookies
    Container::Torrent.new(arguments)
  end
  
  # Returns errors from the application.
  # Return type: A list of strings
  def errors
    self.results; @errors.uniq
  end
  
  def results
    return @torrents if @torrents.any?
    counter  = 0
    rejected = 0
    self.inner_torrents(self.content).each do |tr|
      counter += 1
      
      torrent = self.create_torrent({
        details: self.inner_details(tr),
        torrent: self.inner_torrent(tr),
        title: self.inner_title(tr).to_s.strip,
        tracker: @tracker
      })
      
      if torrent.valid?
        @torrents << torrent
      else
        rejected += 1
      end 
    end
    
    @errors << "#{counter} torrents where found, #{rejected} where not valid" unless rejected.zero?
    return @torrents
  end
end