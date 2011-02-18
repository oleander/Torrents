require 'spec_helper'
def valid_url
  /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
end

def debugger
  true
end

def rest_client(url, file = "recent")
  RestClient.should_receive(:get).with(url, {:timeout => 10}).at_least(1).times.and_return(File.read("spec/data/the_pirate_bay/#{file}.html"))
end

describe Torrents do  
  it "should contain the right type when trying to do a search" do
    rest_client("http://thepiratebay.org/search/chuck/0/99/0", "search")
    torrents = Torrents.the_pirate_bay.debugger(debugger).search("chuck").results
    torrents.each do |torrent|
      torrent.details.should be_instance_of(String)
      torrent.title.should be_instance_of(String)
      torrent.seeders.should be_instance_of(Fixnum)
      torrent.torrent.should be_instance_of(String)
      torrent.should be_valid
    end
  end
  
  it "should contain the right type when trying to do fetch the most recent torrent" do
    rest_client("http://thepiratebay.org/recent/1")
    torrents = Torrents.the_pirate_bay.page(1).debugger(debugger).results
    torrents.each do |torrent|
      torrent.details.should be_instance_of(String)
      torrent.title.should be_instance_of(String)
      torrent.seeders.should be_instance_of(Fixnum)
      torrent.torrent.should be_instance_of(String)
      torrent.should be_valid
    end
  end
  
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
  
  it "should contain 100 torrents" do
     rest_client("http://thepiratebay.org/recent/1")
     Torrents.the_pirate_bay.debugger(debugger).page(1).results.count.should eq(30)
   end
   
   it "should contain a detailed link" do
     rest_client("http://thepiratebay.org/recent/1")
     details = Torrents.the_pirate_bay.debugger(debugger).page(1).results.first.details
     details.should match(/http:\/\/thepiratebay\.org\/torrent\/\d+\/.+/i)
     details.should match(valid_url)
   end
   
    it "should contain a torrent url" do
      rest_client("http://thepiratebay.org/recent/1")
      torrent = Torrents.the_pirate_bay.debugger(debugger).page(1).results.first.torrent
      torrent.should match(/http:\/\/torrents\.thepiratebay\.org\/\d+\/.+\.torrent$/i)
      torrent.should match(valid_url)
    end
    
    it "should contain a title without html tags" do
      rest_client("http://thepiratebay.org/recent/1")
      Torrents.the_pirate_bay.debugger(debugger).page(1).results.first.title.should_not match(/<\/?[^>]*>/)
    end
   
    it "should contain the right instances" do
      rest_client("http://thepiratebay.org/recent/1")
      Torrents.the_pirate_bay.debugger(debugger).page(1).results.first.should be_instance_of(Container::Torrent)
    end
    
    it "should be possible to search for a string, for real" do
      rest_client("http://thepiratebay.org/search/chuck/0/99/0", "search")
      Torrents.the_pirate_bay.debugger(debugger).search("chuck").results.first.details.should match(/\d+/)
      Torrents.the_pirate_bay.debugger(debugger).search("chuck").results.last.details.should match(/\d+/)    
      Torrents.the_pirate_bay.debugger(debugger).search("chuck").results.count.should eq(30)
    end
    
    it "should not contain any html tags" do
      rest_client("http://thepiratebay.org/search/chuck/0/99/0", "search")
      Torrents.the_pirate_bay.debugger(debugger).search("chuck").results.each do |torrent|
        [:details, :torrent, :title, :dead?, :seeders].each do |method|
          torrent.send(method).to_s.should_not match(/<\/?[^>]*>/)
        end
      end
    end
    
    it "should not return anything if nothing is being downloaded" do
      rest_client("http://thepiratebay.org/search/chuck/0/99/0", "empty")
      Torrents.the_pirate_bay.debugger(debugger).search("chuck").results.should be_empty
    end
    
    it "should be possible to search for a string containing whitespace" do
      Torrents.the_pirate_bay.debugger(debugger).search("die hard").should have(30).results
    end
end