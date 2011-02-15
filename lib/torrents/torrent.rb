module Container
  require 'rest_client'
  require 'nokogiri'
  
  class Torrent
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
    def seeders
      self.content.at_css(@tracker["css"]["seeders"]).content.to_i
    end
    
    protected
      def download
        RestClient.get self.downloadable(self.details), {:timeout => 10}
      end

      def downloadable(url)
        @tracker["url"] + "/" + url.gsub(/#{@tracker["url"]}\//, '').gsub(/[^a-z\/]/i) { |m| CGI::escape(m) }
      end
      
      def content
        Nokogiri::HTML self.download
      end
  end
end