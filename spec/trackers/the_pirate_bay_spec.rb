describe Trackers::ThePirateBay do  
  def rest_client(url, type)
    RestClient.should_receive(:get).with(url, {:timeout => 10}).any_number_of_times.and_return(File.read("spec/data/the_pirate_bay/#{type}.html"))
  end
  
  def valid_url
    /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
  end
  
  def debugger
    false
  end
  
  it "should only list torrents with the right title" do
    rest_client("http://thepiratebay.org/search/chuck/0/99/0", "search")
    torrents = Torrents.the_pirate_bay.debugger(debugger).search("chuck")
    
    torrents.results.each do |torrent|
      torrent.details.should match(/http:\/\/thepiratebay\.org\/torrent\/\d+\/.+/i)
      torrent.title.should match(/chuck/i)
      torrent.torrent.match(/http:\/\/torrents\.thepiratebay\.org\/\d+\/.+\.torrent$/i)
      torrent.should be_valid
    end
    
    torrents.should have(30).results
  end
end