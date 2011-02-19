require 'spec_helper'

def rest_client(url, file = "recent")
  RestClient.should_receive(:get).with(url, {:timeout => 10}).at_least(1).times.and_return(File.read("spec/data/the_pirate_bay/#{file}.html"))
end

describe Torrents do  
  before(:each) do
    @torrents = Torrents.new
  end
  
  context "the exists? method" do
    it "should know if a tracker exists or not" do
      @torrents.exists?("the_pirate_bay").should be_true
      @torrents.exists?("random").should be_false
    end
  end
  
  context "the content method" do
    it "should return a nokogiri object" do
      @torrents.should_receive(:url).and_return("data")
      @torrents.should_receive(:download).with("data").and_return("more data")
      @torrents.content.should be_instance_of(Nokogiri::HTML::Document)
    end
  end
  
  context "the inner_page method" do
    it "should return the right value when using the setter method page" do
      @torrents.page(3)
      @torrents.inner_page.should eq("3")
    end
    
    it "should return the pre defined value" do
      @torrents.should_receive(:inner_start_page_index).and_return(99)
      @torrents.inner_page.should eq("99")
    end
  end
  
  context "the url method" do
    before(:each) do
      @torrents.should_receive(:inner_page).and_return("3")
    end
    
    it "should return the correct url when the searching" do
      @torrents.search("search")
      @torrents.should_receive(:send).and_return("before_<SEARCH>_middle_<PAGE>_after")
      @torrents.url.should eq("before_search_middle_3_after")
    end
    
    it "should work when not searching" do
      @torrents.should_receive(:send).and_return("before_middle_<PAGE>_after")
      @torrents.url.should eq("before_middle_3_after")
    end
  end
  
  context "the add, page, debugger, search method" do
    it "add" do
      @torrents.add("random").should be_instance_of(Torrents)
    end
    
    it "page" do
      @torrents.page("value").should be_instance_of(Torrents)
    end
    
    it "debugger" do
      @torrents.debugger("value").should be_instance_of(Torrents)
    end
    
    it "search" do
      @torrents.search("value").should be_instance_of(Torrents)
    end
  end
  
  context "the method_missing missing" do
    it "should call inner_call when calling method_missing" do
      @torrents.should_receive(:inner_call).with(:example, "a").and_return("b")
      @torrents.method_missing(:inner_example, "a").should eq("b")
    end
    
    it "should raise an exception" do
      lambda {
        @torrents.method_missing(:example, "a")
      }.should raise_error(NoMethodError)
    end
  end
end


# user is trying to do some funky stuff to the data
# def method_missing(method, *args, &block)
#   return self.inner_call($1, args.first) if method =~ /^inner_(.+)$/
#   super(method, args, block)
# end
