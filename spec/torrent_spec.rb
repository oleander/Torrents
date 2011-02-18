require 'spec_helper'
def create_torrent(args = {details: "http://thepiratebay.org/torrent/6173093/", torrent: "http://torrents.thepiratebay.org/6173093/value.torrent", title: "The title", tracker: "the_pirate_bay"})
  Container::Torrent.new(args)
end

def rest_client
  RestClient.should_receive(:get).with("http://thepiratebay.org/torrent/6173093/", {:timeout => 10}).any_number_of_times.and_return(File.read('spec/data/the_pirate_bay/details.html'))
end

describe Container::Torrent do
  before(:all) do
    @torrent = create_torrent
    @methods = {:details => String, :torrent => String, :title => String, :seeders => Fixnum, :dead? => [TrueClass, FalseClass]}
  end
  
  before(:each) do
    
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
    ["a", "a", ""].permutation.to_a.uniq.each do |invalid|
      create_torrent({details: invalid[0], torrent: invalid[1], title: invalid[2], tracker: 'the_pirate_bay'}).should_not be_valid
    end
    
    ["a", "a", nil].permutation.to_a.uniq.each do |invalid|
      create_torrent({details: invalid[0], torrent: invalid[1], title: invalid[2], tracker: 'the_pirate_bay'}).should_not be_valid
    end
    
    create_torrent({details: "a", torrent: "a", title: "a", tracker: "a"}).should be_valid
  end
end