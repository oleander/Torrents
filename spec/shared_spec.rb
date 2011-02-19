require 'spec_helper'

describe Container::Shared do
  before(:each) do
    @shared = Container::Shared.new
  end
  it "should return an empty string when trying to download an empty or non valid URL" do
    @shared.download("non_working_url").should be_empty
    @shared.download(nil).should be_empty
  end
  
  it "should return the content of the site if called with the right url" do
    RestClient.should_receive(:get).with("http://example.com", {:timeout => 10}).exactly(1).times.and_return("123")
    @shared.download("http://example.com").should eq("123")
  end
  
  it "should have a error method" do
    lambda {
      @shared.error("some message")
      @shared.error("some message", "other")
    }.should_not raise_error(Exception)
  end
end