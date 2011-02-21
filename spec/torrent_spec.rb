require 'spec_helper'

describe Container::Torrent do
  def create_torrent(args = {details: "http://thepiratebay.org/torrent/6173093/", torrent: "http://torrents.thepiratebay.org/6173093/value.torrent", title: "The title", tracker: "the_pirate_bay"})
    Container::Torrent.new(args)
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
    RestClient.should_receive(:get).with("http://thepiratebay.org/torrent/6173093/", {:timeout => 10, :cookies => nil}).any_number_of_times.and_return(File.read('spec/data/the_pirate_bay/details.html'))
  end
  
  before(:all) do
    @torrent = create_torrent
    @methods = {:details => String, :torrent => String, :title => String, :seeders => Fixnum, :dead? => [TrueClass, FalseClass]}
  end
  
  it "should contain the right accessors" do
    rest_client
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
end