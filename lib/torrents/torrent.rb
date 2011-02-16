module Container
  require 'rest_client'
  require 'nokogiri'
  require 'torrents/trackers/the_pirate_bay'
  require '/Users/linus/Documents/Projekt/rchardet/lib/rchardet'
  require "iconv"
  
  class Shared
    def download(url)
      begin
        data = RestClient.get url, {:timeout => 10}
        cd = CharDet.detect(data)
        return (cd['confidence'] > 0.6) ? Iconv.conv(cd['encoding'], "UTF-8", data) : data
      rescue
        self.error("Something when wrong when trying to fetch #{url}", "")
      end
      # We do not want the application to crash, there for we return a parseable string
      return ""
    end
    
    def error(messages, error = "")
      messages = messages.class == Array ? messages : [messages]
      STDERR.puts "The Torrent Gem"
      STDERR.puts "\t" + messages.join("\n\t")
      STDERR.puts "\t" + error.inspect
      STDERR.puts "\n\n"
    end
    
    def inner_call(method, tr)
      #begin
        return self.send(method, tr.first)
      #rescue
      #  STDERR.puts "An error in the #{method} method occurred"
      #  STDERR.puts "==> \t#{$!.inspect}"
      #end
      
      #return ""
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
      [:details, :torrent, :title].each do |method|
        return false if self.send(method).nil?
      end

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