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
end