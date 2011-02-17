module Container
  require "rest_client"
  require "nokogiri"
  require "torrents/trackers/the_pirate_bay"
  require 'rchardet19'
  require "iconv"
    
  class Shared      
    def self.debugger(value)
      @debug = value
    end
    
    # Downloads the URL, returns an empty string if an error occurred
    # Here we try to convert the downloaded content to UTF8, 
    # if we"re at least 60% sure that the content that was downloaded actally is was we think
    # The timeout is set to 10 seconds, after that time, an empty string will be returned 
    # {url} (String) The URL to download
    def download(url)
      begin
        data = RestClient.get self.url_cleaner(url), {:timeout => 10}
        cd = CharDet.detect(data)
        return (cd["confidence"] > 0.6) ? (Iconv.conv(cd["encoding"] + "//IGNORE", "UTF-8", data) rescue data) : data
      rescue
        self.error("Something when wrong when trying to fetch #{url}", $!)
      end; ""
    end
    
    # Prints a nice(er) error to the console if something went wrong
    # This is only being called when trying to download or when trying to parse a page
    # {messages} (String) The custom error to the user
    # {error} (Exception) The actual error that was thrown
    # TODO: Don"t print any errors if the debuger is set to {false}
    def error(messages, error = "")
      return unless @debug
      messages = messages.class == Array ? messages : [messages]
      warn "An error in the Torrents gem occurred"
      warn "==> " + messages.join("\n\t")
      warn "==> " + error.inspect[0..50] + " ..."
      warn "\n\n"
    end
    
    # A middle caller that can handle errors for external trackers
    # If the tracker that is being loaded in {load} craches, 
    # then this makes sure that the entire application won"t crash
    # {method} (Hash) The method that is being called inside the trackers module
    # {tr} (Nokogiri | [Nokogiri]) The object that contains the HTML content of the current row
    def inner_call(method, tr = nil)
      begin
        x = self.load.send(method, (tr.class == Array ? tr.first : tr))
        return x
      rescue
        self.error("{inner_call} An error in the #{method} method occurred", $!)
      end; {
        torrent: "",
        torrents: [],
        seeders: 1,
        title: "",
        details: ""
      }[method]
    end
    
    # Creating a singleton of the {tracker} class
    # {tracker} (String) The tracker to load
    def load(tracker = nil)
      @load ||= Trackers::ThePirateBay.new
    end
    
    def url_cleaner(url)
      url.gsub(/\{|\}|\||\\|\^|\[|\]|\`|\s+/) { |m| CGI::escape(m) }
    end
  end
  
  class Torrent < Shared
    attr_accessor :details, :torrent, :title, :seeders
    
    def initialize(args)
      args.keys.each { |name| instance_variable_set "@" + name.to_s, args[name] }
      Container::Shared.debugger(@debug)
    end
    
    # Is the torrent dead?
    # The definition of dead is; no seeders
    # Returns a boolean
    def dead?
      self.seeders <= 0
    end
    
    # Returns the amount of seeders for the current torrent
    # If the seeder-tag isn't found, the value one (1) will be returned.
    # Returns an integer from 0 to inf
    def seeders
      return @seeders if @seeders
      seeders = self.inner_call(:seeders, self.content)
      @seeders ||= (seeders.nil? or seeders.to_s.empty? ? 1 : seeders).to_i
    end
    
    # Is the torrent valid?
    # The definition of valid:
    #   Non of the accessors
    #   => is nil
    #   => contains htmltags
    #   => starts or ends with whitespace
    # Returns {true} or {false}
    def valid?
      [:details, :torrent, :title].each do |method|
        data = self.send(method)
        return false if self.send(method).nil? or data.to_s.empty? or data.to_s.match(/<\/?[^>]*>/) or data.to_s.strip != data.to_s
      end; true
    end
    
    # Downloads the detailed view for this torrent
    # Returns an Nokogiri object
    def content
      @content ||= Nokogiri::HTML self.download(@details)
    end
  end
end