describe Trackers::Torrentleech do  
  def rest_client(url, type)
    RestClient.should_receive(:get).with(url, {:timeout => 10, :cookies => cookies}).any_number_of_times.and_return(File.read("spec/data/torrentleech/#{type}.html"))
  end
  
  def cookies
    authentication["cookies"]
  end
  
  def authentication
    YAML::load(File.read("authentication/torrentleech.yaml"))
  end
  
  def create_torrent
    Container::Torrent.new({
      details: "http://www.torrentleech.org/torrent/281171", 
      torrent: "http://www.torrentleech.org/download/281171/The.Tourist.2010.720p.BRRip.x264-TiMPE.torrent", 
      title: "The title", 
      tracker: "torrentleech",
      cookies: cookies
    })
  end
  
  it "should only list torrents with the right title" do
    rest_client("http://www.torrentleech.org/torrents/browse/index/query/dvd/page/1", "search")
    torrents = Torrents.torrentleech.cookies(cookies).search("dvd")
    
    torrents.results.each do |torrent|
      torrent.title.should_not eq(torrent.torrent)
      torrent.id.should_not eq(0)
    end
    
    torrents.should have(100).results
  end
  
  it "should be possible to parse the details view" do
    rest_client("http://www.torrentleech.org/torrent/281171", "details")
    torrent = create_torrent
    
    torrent.seeders.should eq(49)
  end
  
  it "should be possible to list recent torrents" do
    rest_client("http://www.torrentleech.org/torrents/browse/index/page/1", "recent")
    Torrents.torrentleech.cookies(cookies).should have(100).results
  end
   
  it "should found 100 recent movies" do
    rest_client("http://www.torrentleech.org/torrents/browse/index/categories/1,8,9,10,11,12,13,14,15,29/page/1", "movies")
    Torrents.torrentleech.cookies(cookies).category(:movies).should have(100).results
  end
  
  it "should have a working find_by_details method" do
    rest_client("http://www.torrentleech.org/torrent/281171", "details")
    torrent = Torrents.torrentleech.cookies(cookies).find_by_details("http://www.torrentleech.org/torrent/281171")
    
    torrent.should_not be_dead
    torrent.seeders.should eq(49)
    torrent.tid.should eq("a64e45a4260991346b632c866e379b06")
    torrent.domain.should eq("torrentleech.org")
    torrent.imdb.should eq("http://www.imdb.com/title/tt1243957")
    torrent.imdb_id.should eq("tt1243957")
    torrent.id.should eq(281171)
    torrent.torrent.should eq("http://www.torrentleech.org/download/281171/The.Tourist.2010.720p.BRRip.x264-TiMPE.torrent")
    torrent.title.should eq("The Tourist 2010 720p BRRip x264-TiMPE")
  end
end