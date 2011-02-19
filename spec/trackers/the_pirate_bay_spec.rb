describe Trackers::ThePirateBay do  
  def rest_client(url, type)
    RestClient.should_receive(:get).with(url, {:timeout => 10}).any_number_of_times.and_return(File.read("spec/data/the_pirate_bay/#{type}.html"))
  end
  
  def create_torrent
    Container::Torrent.new({
      details: "http://thepiratebay.org/torrent/6173093/", 
      torrent: "http://torrents.thepiratebay.org/6173093/value.torrent", 
      title: "The title", 
      tracker: "the_pirate_bay" 
    })
  end
  
  it "should only list torrents with the right title" do
    rest_client("http://thepiratebay.org/search/chuck/0/99/0", "search")
    torrents = Torrents.the_pirate_bay.search("chuck")
    
    torrents.results.each do |torrent|
      torrent.details.should match(/http:\/\/thepiratebay\.org\/torrent\/\d+\/.+/i)
      torrent.title.should match(/chuck/i)
      torrent.torrent.match(/http:\/\/torrents\.thepiratebay\.org\/\d+\/.+\.torrent$/i)
    end
    
    torrents.should have(30).results
  end
  
  it "should be possible to parse the details view" do
    rest_client("http://thepiratebay.org/torrent/6173093/", "details")
    torrent = create_torrent
    
    torrent.should be_valid    
    torrent.seeders.should eq(9383)
    torrent.should_not be_dead
  end
  
  it "should be possible to list recent torrents" do
    rest_client("http://thepiratebay.org/recent/5", "recent")
    torrents = Torrents.the_pirate_bay.page(5)
    torrents.should have(30).results
    torrents.results.each do |torrent|
      torrent.details.should match(/http:\/\/thepiratebay\.org\/torrent\/\d+\/.+/i)
      torrent.torrent.match(/http:\/\/torrents\.thepiratebay\.org\/\d+\/.+\.torrent$/i)
    end
  end
end