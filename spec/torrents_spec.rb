require 'spec_helper'
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
    Torrents.the_pirate_bay.search("string").url.should eq("http://thepiratebay.org/search/string/0/99")
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
    Torrents.the_pirate_bay.page(1).count.should eq(30)
  end
  
  it "should contain a detailed link" do
    Torrents.the_pirate_bay.page(1).first.details.should match(/http:\/\/thepiratebay\.org\/torrent\/\d+\/.+/i)
  end
end