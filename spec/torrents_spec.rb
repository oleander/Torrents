require 'spec_helper'
def valid_url
  /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
end

def rest_client(url, file = "recent")
  RestClient.should_receive(:get).with(url, {:timeout => 10}).any_number_of_times.and_return(File.read("spec/data/the_pirate_bay/#{file}.html"))
end

describe Torrents do  
  it "should only respond to that exists in the trackers yaml file" do
    lambda {
      Torrents.the_pirate_bay
    }.should_not raise_error(Exception)
    
    lambda {
      Torrents.random_site
    }.should raise_error(Exception)
  end
  
  it "should be possible to add a search string" do
    Torrents.the_pirate_bay.search("string").url.should eq("http://thepiratebay.org/search/string/0/99/0")
  end
  
  it "should be possible to specify a page" do
    Torrents.the_pirate_bay.page(5).url.should eq("http://thepiratebay.org/recent/5")
  end
  
  it "should raise an error if the method does not exist" do
    lambda {
      Torrents.the_pirate_bay.random
    }.should raise_error(NoMethodError)
  end
  
  it "should not be possible to access the torrents from outside the scope" do
    lambda {
      Torrents.the_pirate_bay.torrents
    }.should raise_error(NoMethodError)  
  end
  
  it "should contain 100 torrents" do
    rest_client("http://thepiratebay.org/recent/1")
    Torrents.the_pirate_bay.page(1).count.should eq(30)
  end
  
  it "should contain a detailed link" do
    rest_client("http://thepiratebay.org/recent/1")
    details = Torrents.the_pirate_bay.page(1).first.details
    details.should match(/http:\/\/thepiratebay\.org\/torrent\/\d+\/.+/i)
    details.should match(valid_url)
  end
  
  it "should contain a torrent url" do
    rest_client("http://thepiratebay.org/recent/1")
    torrent = Torrents.the_pirate_bay.page(1).first.torrent
    torrent.should match(/http:\/\/torrents\.thepiratebay\.org\/\d+\/.+\.torrent$/i)
    torrent.should match(valid_url)
  end
  
  it "should contain a title without html tags" do
    rest_client("http://thepiratebay.org/recent/1")
    Torrents.the_pirate_bay.page(1).first.title.should_not match(/<\/?[^>]*>/)
  end
  
  it "should contain the right instances" do
    rest_client("http://thepiratebay.org/recent/1")
    Torrents.the_pirate_bay.page(1).first.should be_instance_of(Container::Torrent)
  end
  
  it "should be possible to search for a string, for real" do
    rest_client("http://thepiratebay.org/search/chuck/0/99/0", "search")
    Torrents.the_pirate_bay.search("chuck").first.details.should match(/6149110/)
    Torrents.the_pirate_bay.search("chuck").last.details.should match(/6093865/)    
    Torrents.the_pirate_bay.search("chuck").count.should eq(30)
  end
  
  it "should not contain any html tags" do
    
    Torrents.the_pirate_bay.search("chuck").to_a.each do |torrent|
      [:details, :torrent, :title, :seeders, :dead?].each do |method|
        torrent.send(method).to_s.should_not match(/<\/?[^>]*>/)
      end
    end
  end
end