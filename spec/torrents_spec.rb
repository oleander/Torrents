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
end