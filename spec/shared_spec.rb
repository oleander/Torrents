require 'spec_helper'

describe Container::Shared do
  before(:each) do
    @shared = Container::Shared.new
  end
  context "the download method" do
    it "should return an empty string when trying to download an empty or non valid URL" do
      @shared.download("non_working_url").should be_empty
      @shared.download(nil).should be_empty
    end

    it "should return the content of the site if called with the right url" do
      RestClient.should_receive(:get).with("http://example.com", {:timeout => 10}).exactly(1).times.and_return("123")
      @shared.download("http://example.com").should eq("123")
    end
  end
  
  context "the error method" do
    it "should have a error method" do
      lambda {
        @shared.error("some message")
        @shared.error("some message", "other")
      }.should_not raise_error(Exception)
    end
  end
  
  context "the inner_call" do
    before(:each) do
      @load = mock(Object)
    end
    
    it "should call an example method with no arguments" do
      @shared.should_receive(:load).and_return(@load)
      @load.should_receive(:example).with.and_return("value") # No arguments
      @shared.inner_call(:example).should eq("value")
    end
    
    it "should call an example method with arguments" do
      @shared.should_receive(:load).and_return(@load)
      @load.should_receive(:example).with("abc").and_return("value") # No arguments
      @shared.inner_call(:example, "abc").should eq("value")
    end
    
    it "should call an example and rescue an exception" do
      @shared.should_receive(:load).and_return(lambda{
        raise NoName.new
      })
      
      @shared.should_receive(:error)
      @shared.should_receive(:default_values).with(:call).and_return("error")
      @shared.inner_call(:call).should eq("error")
    end
  end
end