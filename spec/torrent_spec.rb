require 'spec_helper'

describe Container::Torrent do
  def create_torrent(args = {details: "http://thepiratebay.org/torrent/6173093/", torrent: "http://torrents.thepiratebay.org/6173093/value.torrent", title: "The title", tracker: "the_pirate_bay"})
    Container::Torrent.new(args)
  end
  
  def valid_url?(url)
    !! url.match(/(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i)
  end
  
  def create_torrents(n)
    torrents = []
    n.times do |n|
      torrents << create_torrent({
        details: "http://thepiratebay.org/torrent/617#{n}093/", 
        torrent: "http://torrents.thepiratebay.org/617093/value.torrent", 
        title: "The title", 
        tracker: "the_pirate_bay"
      })
    end
    
    torrents
  end
  
  def rest_client
    RestClient.should_receive(:get).with("http://thepiratebay.org/torrent/6173093/", {:timeout => 10, :cookies => nil}).at_least(1).times.and_return(File.read('spec/data/the_pirate_bay/details.html'))
  end
  
  before(:all) do
    @torrent = create_torrent
    @methods = {:details => String, :torrent => String, :title => String, :seeders => Fixnum, :dead? => [TrueClass, FalseClass]}
  end
  
  it "should contain the right accessors" do
    @methods.each do |method, _|
      @torrent.methods.should include(method)
    end
  end
  
  it "should have the right return type" do
    rest_client
    @methods.each do |method, type|
      type.class == Array ? (type.should include(@torrent.send(method).class)) : (@torrent.send(method).should be_instance_of(type))
    end
  end
  
  it "should have a working valid? method" do
    [["a", "a", ""], ["a", "a", nil], ["a", "a", "<tag>"], ["a", "a", " a"], ["a", "http://google.com", "a"], ["a", "http://google.com.torrent", "a"], ["a", "http://google.com", "a.torrent"]].each do |option|
      option.permutation.to_a.uniq.each do |invalid|
        create_torrent({details: invalid[0], torrent: invalid[1], title: invalid[2], tracker: 'the_pirate_bay'}).should_not be_valid
      end
    end
     
    create_torrent({details: "http://google.com/123/", torrent: "http://google.com.torrent", title: "a", tracker: "the_pirate_bay"}).should be_valid
    create_torrent({details: "http://google.com/random/", torrent: "http://google.com.torrent", title: "a", tracker: "the_pirate_bay"}).id.should eq(0)
  end
  
  it "should be dead" do
    torrent = create_torrent({details: "a", torrent: "a", title: "a", tracker: "a"})
    torrent.should_receive(:seeders).and_return(0)
    torrent.should be_dead
  end
  
  it "should not be dead" do
    torrent = create_torrent
    torrent.should_receive(:seeders).and_return(1)
    torrent.should_not be_dead
  end
  
  it "should return the right amount of seeders if it's nil" do
    torrent = create_torrent
    torrent.should_receive(:valid_option?).and_return(false)
    torrent.seeders.should eq(1)
  end
  
  it "should return the right amount of seeders if it's set" do
    torrent = create_torrent
    torrent.should_receive(:inner_call).and_return(50)
    torrent.seeders.should eq(50)
  end
  
  it "should be able to cache requests" do
    torrent = create_torrent
    torrent.should_receive(:download).exactly(1).times.and_return("")
    10.times { torrent.seeders }
  end
  
  it "should have a id method" do
    torrent = create_torrent
    torrent.id.should eq(6173093)
  end
  
  it "should have an id 0 if the details url is invalid" do
    torrent = create_torrent({
      details: "http://thepiratebay.org/torrent/random/", 
      torrent: "http://torrents.thepiratebay.org/6173093/value.torrent", 
      title: "The title", 
      tracker: "the_pirate_bay"
    })
    
    torrent.id.should eq(0)
  end
  
  it "should have a unique tid (torrent id)" do
    torrents = create_torrents(100)
    
    torrents.map!(&:tid)
    lambda do
      torrents.uniq!
    end.should_not change(torrents, :count)
  end
  
  it "should have a torrent id method that equals the tid method" do
    create_torrents(100).each do |torrent|
      torrent.torrent_id.should eq(torrent.tid)
    end
  end
  
  it "should have a working imdb method" do
    rest_client
    
    valid_url?(create_torrent.imdb).should be_true
    create_torrent.imdb.should eq("http://www.imdb.com/title/tt0990407")
  end
  
  it "should have a working imdb_id method" do
    rest_client
    
    create_torrent.imdb_id.should eq("tt0990407")
  end
  
  it "should call the find_movie_by_id if a movie if found" do
    rest_client
    MovieSearcher.should_receive(:find_movie_by_id).with("tt0990407").and_return("123")
    
    create_torrent.movie.should eq("123")
  end
  
  it "should call the find_by_release_name if no movie was found" do
    torrent = create_torrent
    torrent.should_receive(:imdb_id).and_return(nil)
    torrent.should_receive(:title).and_return("my title")
    MovieSearcher.should_receive(:find_by_release_name).with("my title", :options => {:details => true}).and_return("456")
    
    torrent.movie.should eq("456")
  end
  
  context "the subtitle method" do
    it "should have a working subtitle method, when a imdb id exists" do
      torrent = create_torrent
      torrent.should_receive(:imdb_id).at_least(1).times.and_return("tt0990407")
      torrent.should_receive(:title).and_return("a subtitle")
      Undertexter.should_receive(:find).with("tt0990407", language: :english).and_return([Struct.new(:title).new("a subtitle")])
  
      torrent.subtitle.title.should eq("a subtitle")
    end
  
    it "should also work when the imdb_id is nil" do
      torrent = create_torrent
      torrent.should_receive(:imdb_id).at_least(1).times.and_return(nil)
      torrent.subtitle.should be_nil
    end
    
    it "should be possible to pass arguments to subtitle" do
      torrent = create_torrent
      torrent.should_receive(:imdb_id).at_least(1).times.and_return("tt0990407")
      torrent.should_receive(:title).and_return("a subtitle")
      Undertexter.should_receive(:find).with("tt0990407", language: :swedish).and_return([Struct.new(:title).new("a subtitle")])
  
      torrent.subtitle(:swedish).title.should eq("a subtitle")
    end
    
    it "should be able to cache a subtitle" do
      torrent = create_torrent
      torrent.should_receive(:imdb_id).any_number_of_times.times.and_return("tt0990407")
      torrent.should_receive(:title).any_number_of_times.and_return("a subtitle")
      Undertexter.should_receive(:find).with("tt0990407", language: :swedish).exactly(1).times.and_return([Struct.new(:title).new("a subtitle")])
      Undertexter.should_receive(:find).with("tt0990407", language: :english).exactly(1).times.and_return([Struct.new(:title).new("a subtitle")])
      
      10.times { torrent.subtitle(:swedish).title.should eq("a subtitle") }
      10.times { torrent.subtitle(:english).title.should eq("a subtitle") }
    end
  end

  
  it "should have a working title, even when the title is empty from the beginning" do
    torrent = create_torrent
    torrent.title.should eq("The title")
  end
  
  it "should have a working torrent method, even when the torrent is empty from the beginning " do
    torrent = create_torrent
    valid_url?(torrent.torrent).should be_true
    torrent.torrent.match(/\.torrent$/)
  end
end