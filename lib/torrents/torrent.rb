module Container
  require 'rest_client'
  require 'nokogiri'
  
  class Shared
    def download(url)
      begin
        return RestClient.get url, {:timeout => 10}
      rescue
        self.error("Something when wrong when trying to fetch #{url}", $!)
      end
        
      # We do not want the application to crash, there for we return a parseable string
      return ""
    end
    
    def error(messages, error = "")
      message = messages.class == Array ? messages : [messages]
      puts "The Torrent Gem"
      puts "\t" + messages.join("\n\t")
      puts "\t" + error
      puts "\n\n"
    end
  end
  
  class Torrent < Shared
    attr_accessor :details, :torrent, :title

    def initialize(args)
      args.keys.each { |name| instance_variable_set "@" + name.to_s, args[name] }
    end
    
    # Is the torrent dead?
    # The definition of dead is; no seeders
    def dead?
      self.seeders <= 0
    end
    
    # Returns the number of seeders
    # {at_css} might in some cases return nil, that what the {rescue} is for
    def seeders
      begin
        return self.content.at_css(@tracker["css"]["seeders"]).content.to_i
      rescue NoMethodError
        self.error(["No seed value where found using #{@tracker["css"]["seeders"]}", "The error occured when trying to fetch #{@details}"])
      end
      
      # If an error occured this will be the default
      return 1
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