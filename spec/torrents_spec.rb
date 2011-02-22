require 'spec_helper'

describe Torrents do
  def rest_client(url, type)
    RestClient.should_receive(:get).with(url, {:timeout => 10, :cookies => nil}).any_number_of_times.and_return(File.read("spec/data/the_pirate_bay/#{type}.html"))
  end
   
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
    it "should not care about the order of the page, high" do
      @torrents.should_receive(:inner_start_page_index).any_number_of_times.and_return(10)
      @torrents.page(1)
      @torrents.inner_page.should eq("10")
    end
    
    it "should return the pre defined value" do
      @torrents.should_receive(:inner_start_page_index).any_number_of_times.and_return(99)
      @torrents.inner_page.should eq("99")
    end
    
    it "should not care about the order of the page, low" do
      @torrents.should_receive(:inner_start_page_index).any_number_of_times.and_return(0)
      @torrents.page(1)
      @torrents.inner_page.should eq("0")
    end
    
    it "should not care about the order of the page, low again" do
      @torrents.should_receive(:inner_start_page_index).any_number_of_times.and_return(1)
      @torrents.page(1)
      @torrents.inner_page.should eq("1")
    end
    
    it "should not care about the order of the page, if the page isn't specified, one" do
      @torrents.should_receive(:inner_start_page_index).any_number_of_times.and_return(1)
      @torrents.inner_page.should eq("1")
    end
    
    it "should not care about the order of the page, if the page isn't specified, high" do
      @torrents.should_receive(:inner_start_page_index).any_number_of_times.and_return(10)
      @torrents.inner_page.should eq("10")
    end
    
    it "should not care about the order of the page, if the page isn't specified, zero" do
      @torrents.should_receive(:inner_start_page_index).any_number_of_times.and_return(0)
      @torrents.inner_page.should eq("0")
    end
    
    it "should raise an exception if the page number is lower then 0" do
      @torrents.should_receive(:inner_start_page_index).any_number_of_times.and_return(0)
      lambda {
        @torrents.page(0)
      }.should raise_error(ArgumentError, "To low page value, remember that the first page has the value 1")
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
      @torrents.category(:movies).page(100).url.should eq("http://thepiratebay.org/browse/201/99/3")
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
      @torrents.page(10).should be_instance_of(Torrents)
    end
    
    it "debugger" do
      @torrents.debugger(true).should be_instance_of(Torrents)
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
  
  context "the cookies method" do
    it "should be possible to pass some cookies" do
      RestClient.should_receive(:get).with("http://thepiratebay.org/recent/0", {:timeout => 10, :cookies => {:session_id => "1234"}}).exactly(1).times.and_return("")
      @torrents.cookies(:session_id => "1234").content
    end
  end
  
  context "the find_by_details method" do
    it "should be possible to add a details link and get appropriate data" do
      rest_client("http://thepiratebay.org/torrent/6173093/", "details")
      torrent = Torrents.the_pirate_bay.find_by_details("http://thepiratebay.org/torrent/6173093/")
      
      # Makes sure that all methods returnes something
      [:seeders, :title, :dead?, :imdb, :imdb_id, :domain, :id].each do |method|
        torrent.send(method).to_s.should_not be_empty
      end
      
      torrent.should_not be_dead
      torrent.seeders.should eq(9383)
      torrent.tid.should_not be_empty
      torrent.domain.should eq("thepiratebay.org")
    end
  end
  
  context "the errors method" do
    before(:each) do
      rest_client("http://thepiratebay.org/recent/0", "recent")
    end
    
    it "should return the right error messages" do
      errors = @torrents.errors
      
      [
        "An error occurred in the the_pirate_bay class at the details method.\n#<NoMethodError: undefined method `attr' for nil:NilClass>", 
        "An error occurred in the the_pirate_bay class at the title method.\n#<NoMethodError: undefined method `content' for nil:NilClass>", 
        "32 torrents where found, 2 where not valid"
      ].each do |error|
        errors.should include(error)
      end
    end
    
    it "should not return any duplicates" do
      errors = @torrents.errors
      lambda do
        errors.uniq!
      end.should_not change(errors, :count)
    end
  end
end