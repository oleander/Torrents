module Trackers
  class Tti
    def details(tr)
      "http://tti.nu" + tr.to_s.match(/(details\.php\?id=\d+)/i).to_a[1]
    end
  
    def torrent(tr)
      "http://tti.nu" + tr.at_css('.direct_download a').attr('href')
    end
  
    def title(tr)
      tr.at_css('td:nth-child(2) b').content.gsub(/\.\.\.$/, "")
    end
  
    def seeders(details)
      details.to_s.match(/(\d+) seeder\(s\)\,/).to_a[1]
    end
    
    def torrents(site)
      site.css('table[border="0"] tr')
    end
    
    def search_url
      "http://tti.nu/browse.php?search=<SEARCH>&page=<PAGE>&incldead=0"
    end
    
    def recent_url
      "http://tti.nu/browse.php?page=<PAGE>&incldead=0"
    end
    
    def start_page_index
      0
    end
    
    def category_url(type)
      {:movies => "http://tti.nu/browse.php?c47=1&c65=1&c59=1&c48=1&page=<PAGE>&incldead=0"}[type]
    end
    
    def id(details)
      details.match(/id=(\d+)/).to_a[1]
    end
  end
end