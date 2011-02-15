require 'spec_helper'

describe Container::Torrent do
  before(:all) do
    @torrent = Container::Torrent.new({
      details: "http://thepiratebay.org/torrent/6173093/",
      torrent: "http://torrents.thepiratebay.org/6173093/value.torrent",
      title: "The title",
      tracker: YAML::load(File.read('lib/torrents/trackers.yaml'))["the_pirate_bay"]
    })
  end
  
  before(:each) do
    RestClient.should_receive(:get).with("http://thepiratebay.org/torrent/6173093/", {:timeout => 10}).any_number_of_times.and_return(File.read('spec/data/the_pirate_bay/details.html'))
  end
  
  it "should return true if the torrent is dead" do
    @torrent.dead?.should be_false
  end
  
  it "should have some seeders" do
    @torrent.seeders.should be_instance_of(Fixnum)
    @torrent.seeders.should eq(9383)
  end
  
  it "should contain some accessors" do
    lambda {
      [:details, :torrent, :title, :seeders, :dead?].each do |method|
        @torrent.send(method)
      end
    }.should_not raise_error(NoMethodError)
  end
end