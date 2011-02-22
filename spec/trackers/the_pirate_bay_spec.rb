describe Trackers::ThePirateBay do  
  def rest_client(url, type)
    RestClient.should_receive(:get).with(url, {:timeout => 10, :cookies => nil}).any_number_of_times.and_return(File.read("spec/data/the_pirate_bay/#{type}.html"))
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
      torrent.title.should match(/chuck/i)
      torrent.title.should_not eq(torrent.torrent)
    end
    
    torrents.should have(30).results
  end
  
  it "should be possible to parse the details view" do
    rest_client("http://thepiratebay.org/torrent/6173093/", "details")
    torrent = create_torrent
      
    torrent.seeders.should eq(9383)
  end
  
  it "should be possible to list recent torrents" do
    rest_client("http://thepiratebay.org/recent/4", "recent")
    Torrents.the_pirate_bay.page(5).should have(30).results
  end
  
  it "should found 30 recent movies" do
    rest_client("http://thepiratebay.org/browse/201/4/3", "movies")
    Torrents.the_pirate_bay.page(5).category(:movies).should have(30).results
  end
  
  it "should have a working find_by_details method" do
    rest_client("http://thepiratebay.org/torrent/6173093/", "details")
    torrent = Torrents.the_pirate_bay.find_by_details("http://thepiratebay.org/torrent/6173093/")
    
    torrent.should_not be_dead
    torrent.seeders.should eq(9383)
    torrent.tid.should eq("bdc14130add1a279625bf3774c12e89d")
    torrent.domain.should eq("thepiratebay.org")
    torrent.imdb.should eq("http://www.imdb.com/title/tt0990407")
    torrent.imdb_id.should eq("tt0990407")
    torrent.id.should eq(6173093)
  end
end