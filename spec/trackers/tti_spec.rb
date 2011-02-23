describe Trackers::Tti do  
  def rest_client(url, type)
    RestClient.should_receive(:get).with(url, {:timeout => 10, :cookies => cookies}).any_number_of_times.and_return(File.read("spec/data/tti/#{type}.html"))
  end
  
  def cookies
    authentication["cookies"]
  end
  
  def authentication
    YAML::load(File.read("authentication/tti.yaml"))
  end
  
  def create_torrent
    Container::Torrent.new({
      details: "http://tti.nu/details.php?id=132470", 
      torrent: "http://tti.nu/download2.php/132230/Macbeth.2010.DVDRip.XviD-VoMiT.torrent", 
      title: "The title", 
      tracker: "tti",
      cookies: cookies
    })
  end
  
  it "should only list torrents with the right title" do
    rest_client("http://tti.nu/browse.php?search=dvd&page=0&incldead=0", "search")
    torrents = Torrents.tti.cookies(cookies).search("dvd")
    
    torrents.results.each do |torrent|
      torrent.title.should_not eq(torrent.torrent)
      torrent.id.should_not eq(0)
    end
    
    torrents.should have(50).results
  end
  
  it "should be possible to parse the details view" do
    rest_client("http://tti.nu/details.php?id=132470", "details")
    torrent = create_torrent
    
    torrent.should be_valid    
    torrent.seeders.should eq(70)
  end
  
  it "should be possible to list recent torrents" do
    rest_client("http://tti.nu/browse.php?page=0&incldead=0", "recent")
    Torrents.tti.cookies(cookies).should have(50).results
  end
  
  it "should return the right details link when trying to fetch recent torrents" do
    rest_client("http://tti.nu/browse.php?page=0&incldead=0", "recent")
    Torrents.tti.cookies(cookies).results.each do |torrent|
      torrent.details.should match(/http:\/\/tti\.nu\/details\.php\?id=\d+/)
    end
  end
  
  it "should found 50 recent movies" do
    rest_client("http://tti.nu/browse.php?c47=1&c65=1&c59=1&c48=1&page=0&incldead=0", "movies")
    Torrents.tti.cookies(cookies).category(:movies).should have(50).results
  end
  
  it "should have a working find_by_details method" do
     rest_client("http://tti.nu/details.php?id=132470", "details")
     torrent = Torrents.tti.cookies(cookies).find_by_details("http://tti.nu/details.php?id=132470")

     torrent.should_not be_dead
     torrent.seeders.should eq(70)
     torrent.tid.should eq("413a6c863f0a8f58180f97a52f635bd3")
     torrent.domain.should eq("tti.nu")
     torrent.imdb.should eq("http://www.imdb.com/title/tt1536044")
     torrent.imdb_id.should eq("tt1536044")
     torrent.id.should eq(132470)
     torrent.torrent.should eq("http://tti.nu/download2.php/132470/Paranormal.Activity.2.2010.UNRATED.NORDIC.PAL.DVDR-iDiFF.torrent")
     torrent.title.should eq("Paranormal.Activity.2.2010.UNRATED.NORDIC.PAL.DVDR-iDiFF")
   end
end