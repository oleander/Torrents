require '/Users/linus/Documents/Projekt/rchardet/lib/rchardet'
require "iconv"
module ThePirateBay
  
  def details(tr)
    "http://thepiratebay.org" + tr.at_css('.detLink').attr('href')
  end
  
  def torrent(tr)
    tr.to_s.match(/(http:\/\/.+\.torrent)/)[1]
  end
  
  def title(tr)
    tr.at_css('.detLink').content
  end
  
  def seeders(details)
    details.to_s.match(/.+<dd>(\d+)<\/dd>/)[1].to_i
  end
end