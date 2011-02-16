module Container
  require 'rest_client'
  require 'nokogiri'
  require 'torrents/trackers/the_pirate_bay'
  require '/Users/linus/Documents/Projekt/rchardet/lib/rchardet'
  require "iconv"
  
  class Shared
    
    # Downloads the URL, returns an empty string if an error occurred
    # Here we try to convert the downloaded content to UTF8, 
    # if we're at least 60% sure that the content that was downloaded actally is was we think
    # The timeout is set to 10 seconds, after that time, an empty string will be returned 
    # {url} (String) The URL to download
    def download(url)
      begin
        data = RestClient.get url, {:timeout => 10}
        cd = CharDet.detect(data)
        return (cd['confidence'] > 0.6) ? Iconv.conv(cd['encoding'], "UTF-8", data) : data
      rescue
        self.error("Something when wrong when trying to fetch #{url}", "")
      end; ""
    end
    
    # Prints a nice(er) error to the console if something went wrong
    # This is only being called when trying to download or when trying to parse a page
    # {messages} (String) The custom error to the user
    # {error} (Exception) The actual error that was thrown
    # TODO: Don't print any errors if the debuger is set to {false}
    def error(messages, error = "")
      messages = messages.class == Array ? messages : [messages]
      STDERR.puts "The Torrent Gem"
      STDERR.puts "\t" + messages.join("\n\t")
      STDERR.puts "\t" + error.inspect
      STDERR.puts "\n\n"
    end
    
    # A middle caller that can handle errors for external trackers
    # If the tracker that is being loaded in {load} craches, 
    # then this makes sure that the entire application won't crash
    # {method} (Hash) The method that is being called inside the trackers module
    # {tr} (Nokogiri) The object that contains the HTML content of the current row
    # TODO: Return a default value if the method raises an exception, 
    #       the empty string does not work in all cases
    def inner_call(method, tr)
      begin
        return self.load.send(method, (tr.class == Array ? tr : [tr]))
      rescue
        STDERR.puts "{inner_call} An error in the #{method} method occurred"
        STDERR.puts "==> \t#{$!.inspect}"
      end; "" # Se till alla ladda ett default-värde baserat på vilken metod det är som annropas
    end
    
    # Creating a singleton of the {tracker} class
    # {tracker} (String) The tracker to load
    def load(tracker = nil)
      @load ||= Trackers::ThePirateBay.new
    end
  end
  
  class Torrent < Shared
    attr_accessor :details, :torrent, :title
    include ThePirateBay
    
    def initialize(args)
      args.keys.each { |name| instance_variable_set "@" + name.to_s, args[name] }
    end
    
    # Is the torrent dead?
    # The definition of dead is; no seeders
    def dead?
      self.inner_call(:seeders, self.content).to_i <= 0
    end
    
    def valid?
      # [:details, :torrent, :title].each do |method|
      #   return false if self.send(method).nil?
      # end

      return true
    end
    
    protected
      def downloadable(url)
        @tracker["url"] + "/" + url.gsub(/#{@tracker["url"]}\//, '').gsub(/[^a-z\/]/i) { |m| CGI::escape(m) }
      end
      
      def content
        Nokogiri::HTML self.download(self.downloadable(self.details))
      end
  end
end