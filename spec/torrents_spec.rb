require 'spec_helper'

describe Torrents do  
  before(:each) do
    @torrents = Torrents.the_pirate_bay
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
    it "should return the correct url when the searching" do
      @torrents.should_receive(:inner_page).and_return("3")
      @torrents.search("search")
      @torrents.should_receive(:send).and_return("before_<SEARCH>_middle_<PAGE>_after")
      @torrents.url.should eq("before_search_middle_3_after")
    end
    
    it "should work when not searching" do
      @torrents.should_receive(:inner_page).and_return("3")
      @torrents.should_receive(:send).and_return("before_middle_<PAGE>_after")
      @torrents.url.should eq("before_middle_3_after")
    end
    
    it "should be possible to list torrents based on a category" do
      @torrents.category(:movies).page(100).url.should eq("http://thepiratebay.org/browse/201/100/3")
    end
    
    it "should raise an exception if trying to fetch a non existing category" do
      lambda {
        @torrents.category(:random).page(100).url
      }.should raise_error(NotImplementedError)
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
    before(:each) do
      @torrent = mock(Object)
    end
    
    it "should call inner_call when calling method_missing" do
      @torrents.should_receive(:inner_call).with(:example, "a").and_return("b")
      @torrents.method_missing(:inner_example, "a").should eq("b")
    end
    
    it "should raise an exception" do
      lambda {
        @torrents.method_missing(:example, "a")
      }.should raise_error(NoMethodError)
    end
    
    it "should also work with the static method" do
      Torrents.should_receive(:new).and_return(@torrent)
      @torrent.should_receive(:exists?).and_return(true)
      @torrent.should_receive(:add).and_return("some")
      Torrents.a_random_method.should eq("some")
    end
    
    it "should also raise an exception" do
      Torrents.should_receive(:new).and_return(@torrent)
      @torrent.should_receive(:exists?).and_return(false)
      lambda {
        Torrents.a_random_method
      }.should raise_error(Exception)
    end
  end
  
  context "the results method" do
    def inner_torrents(times)
      list = []
      times.times {list << 1}
      @torrents.should_receive(:inner_torrents).exactly(1).times.and_return(list)
    end
    
    def prepare
      torrent = mock(Object)
      inner_torrents(50)
      Container::Torrent.should_receive(:new).any_number_of_times.and_return(torrent)
      torrent.should_receive(:valid?).any_number_of_times.and_return(true)
    end
    
    before(:each) do
      @torrents.should_receive(:content).and_return("")
    end
    
    it "should return an empty list" do
      inner_torrents(0)
      @torrents.results.should be_empty
    end
    
    it "should return a list with items" do
      prepare
      @torrents.should have(50).results
    end
    
    it "should be able to cache torrents" do
      prepare
      5.times { @torrents.should have(50).results }
    end
  end
  
end