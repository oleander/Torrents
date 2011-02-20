# Torrents

Search and download torrents from your favorite bittorrent tracker using Ruby.

## How to use

### Search for a torrent

    >> Torrents.the_pirate_bay.search("chuck").results
    
### List recent torrents

    >> Torrents.the_pirate_bay.results
    
### List recent torrents - with category

    >> Torrents.the_pirate_bay.category(:movies).results
    
### Specify a page

The `page` method can be places anywhere before the `results` method.

    >> Torrents.the_pirate_bay.page(6).results

### Specify some cookies

Some trackers requires cookies to work, even though [The Pirate Bay](http://thepiratebay.org/) is not one of them.

    >> Torrents.the_pirate_bay.cookies(user_id: "123", hash: "c4656002ce46f9b418ce72daccfa5424").results

## What is being returned?

As soon as you apply the `results` method on the query it will try to execute your request.

It will return a list of `Container::Torrent` object is the request was sucessfull, otherwise it will return an empty list.

The `Container::Torrent` class has some nice accessors that might be useful.

- **title** (String) Title of the torrent.
- **details** (String) The url to the details page for the torrent.
- **seeders** (Fixnum) The amount of seeders for the torrent. **Note:** Keep in mind that it will do another request to the details url to get this info. 
- **dead?** (Boolean) Check to see if the torrent has no seeders. If it has no seeders, then `dead?` will be true. **Note:** See the *seeders* method.
- **torrent** (String) The url to the torrent. This should be a direct link to the torrent.
- **id** (Fixnum) An unique id for the torrent. The id is only unique for this specific torrent, not all torrents.
- **tid** (String) The `tid` method, also known as `torrent id` is a *truly* unique identifier for all torrents. It is generated using a [MD5](http://sv.wikipedia.org/wiki/MD5) with the torrent domain and the `id` method as a seed.

## What sites are implemented?

### Open trackers (does not require authentication)

- [The Pirate Bay](http://thepiratebay.org/)

### Closed trackes (requires authentication)

- [TTI](http://tti.nu/)
- [Torrentleech](http://www.torrentleech.org/)


## How to add your own tracker

All heavy lifting has already been done, so it should be quite easy for you to implement your own site.

This is a short tutorial of how to implement the *Super Tracker*

### The work flow

1. Make a fork of this project.
2. Implement your tracker acordning to the specifications below.
3. Build and run the gem local, agains a real server.
4. Do a pull request.

If you have troubles implementing your tracker, please contanct me and I'll help you get started.

### Create the cache

The first thing to do is to create a local cache to read from during testing.
You need an HTML template for 4 diffrent page.

- **Search** *search.html* - The page containing a search result.
- **Details** *details.html* - The details view for any torrent.
- **Movies** *movies.html* - Recent torrents from the movie category.
- **Recent** *recent.html* - The most recent torrents on the site.

Save the files to `spec/data/*super_tracker*`. 
Take a look at the pirate bay example files [here](https://github.com/oleander/Torrents/tree/master/spec/data/the_pirate_bay).

**Note:** Be sure to remove your personal information from the HTML files, like username and user id.

### Implement the tracker class

Next step is to implement the 10 methods to parse the tracker.

Create a class called *super_tracker* inside `lib/torrents/trackers`.

Add this skeleton to the newly created file.

    module Trackers
      class SuperTracker
        def details(tr)
          # TODO
        end
  
        def torrent(tr)
          # TODO
        end
  
        def title(tr)
          # TODO
        end
  
        def seeders(details)
          # TODO
        end
    
        def torrents(site)
          # TODO
        end
    
        def search_url
          # TODO
        end
    
        def recent_url
          # TODO
        end
    
        def start_page_index
          # TODO
        end
    
        def category_url(type)
          # TODO
        end
    
        def id(details)
          # TODO
        end
      end
    end

#### This is how it all works

When someone calls `Trackers.super_tracker` the `SuperTracker` class will be called.

When the Tracker class need inforamtion about something, like the amount of seeders, the `SuperTracker` will be called.

#### Methods to implement

The methods in the Tracker module will be called with some arguments that you have to modify and return.

These are the methods and what they are being called with.

##### details

Argument: `Nokogiri::XML::Element` object representing a table row.

Returnes: The full url to the details page for the torrent of the current row.

##### torrent

Argument: `Nokogiri::XML::Element` object representing a table row.

Returnes: The full url to the torrent for of current row.

##### title

Argument: `Nokogiri::XML::Element` object representing a table row.

Returnes: The title of the torrent for of current row.

##### seeders

Argument: `Nokogiri::HTML::Document` object representing the details page.

Returnes: The amount of seeders for the specific torrent.

##### torrents

Argument: `Nokogiri::HTML::Document` object representing the torrent table.

Returnes: A list of `Nokogiri::XML::Element` object representing a list of rows.

##### search_url

Argument: none

Returnes: The url to be used when searching for a torrent.

##### recent_url

Argument: none

Returnes: The url to be used when lising the most recent torrents.

##### start_page_index

Argument: none

Returnes: The index to be used as the start page.

##### category_url

Argument: A `Symbol` representing the category search for.

Returnes: The category url for the ingoing argument.

##### id

Argument: A `String` representing the details url.

Returnes: The id for the torrent, parsed from the details url.

#### Example class

You can take a look at the [Pirate Bay example](https://github.com/oleander/Torrents/blob/master/lib/torrents/trackers/the_pirate_bay.rb) if something is unclear. 


#### Things you *don't* have to take into aspect.

There are some things that you don't have to think about when implementing the `Tracker` class.
The `Tracker` class will solve the problems for you.

- The return type of the methods. Just returning a string works fine. [KISS](http://en.wikipedia.org/wiki/KISS_principle).
- Error handling. Sometimes you can't find a CSS selector that that matches exactly 50 torrents in the table, that does't matter. Do your best and `Torrents` will handle the rest.
- Default values. If some selector isn't found `Torrents` will fallback on a default value.

#### What happens if my method returns something strange 1 out of 100 times?

That does't matter, if your parser for some reason returnes some strange value the `Torrent` class will find the error when validaing the ingoing data. 

The torrent containing the invalid data will just be ignored.

Your implementation must still pass some basic tests, see below.

### Test your implementation

Start by creating a skeleton testcase by copying [the pirate bay](https://github.com/oleander/Torrents/blob/master/spec/trackers/the_pirate_bay_spec.rb) test case.

Create you own test inside the `spec/trackers`.

#### Stuff to test

The following should be covered in your test.

- When searching for a string, the correct amount of torrents should be returned
- It should be possible to get the amount of seeders, the value 0 means fail (it's the default value)
- It should be possible to get the page {n}, where {n} is any given page
- It should be possible to list the recent torrents
- It should be possible to get the movie category

### The readme

Add the new site to the readme.

There should be a list in the upper part of the document.

### When done

Do a pull request, if some small part of your implementation if missing I'll contact you so we can solve it together.

## How do install

    [sudo] gem install torrents
    
## How to use it in a rails 3 project

Add `gem 'torrents'` to your Gemfile and run `bundle`.

## Requirements

Torrents is tested in OS X 10.6.6 using Ruby 1.9.2.