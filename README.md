# Torrents

Search and download torrents and subtitle from your favorite bittorrent tracker using Ruby.

## Which trackers are implemented at the moment?

### Open trackers

- [The Pirate Bay](http://thepiratebay.org/)

### Closed trackes

- [TTI](http://tti.nu/)
- [Torrentleech](http://www.torrentleech.org/)

## How to use

### Search for a torrent

    >> Torrents.the_pirate_bay.search("chuck").results
    
### List recent torrents

    >> Torrents.the_pirate_bay.results
    
### List recent torrents - with category

    >> Torrents.the_pirate_bay.category(:movies).results
    
### Specify a page

The `page` method can be places anywhere before the `results` method.

It starts counting from `1` and goes up, no matter what is used on the site it self.

    >> Torrents.the_pirate_bay.page(6).results

### Specify some cookies

Some trackers requires cookies to work, even though [The Pirate Bay](http://thepiratebay.org/) is not one of them.

    >> Torrents.the_pirate_bay.cookies(user_id: "123", hash: "c4656002ce46f9b418ce72daccfa5424").results

## What methods to work with

### The results method

As soon as you apply the `results` method on the query it will try to execute your request.
If you for example want to activate the debugger, define some cookies and specify a page, then you can do it like this.
      
      $ Torrents.the_pirate_bay.page(5).debug(true).cookies(:my_cookie => "value").results
      
It will return a list of `Container::Torrent` object if the request was sucessfull, otherwise it will return an empty list.

### The find_by_details method

If you have access to a single details link and want to get some useful data from it, then `find_by_details` might fit you needs.

The method takes the url as an argument and returnes a single `Container::Torrent` object.

    $ Torrents.the_pirate_bay.find_by_details("http://thepiratebay.org/torrent/6173093/")

# What data to work with

### The Container::Torrent class

It has some nice accessors that might be useful.

- **title** (String) The title.
- **details** (String) The url to the details page.
- **seeders** (Fixnum) The amount of seeders.
- **dead?** (Boolean) Check to see if the torrent has no seeders. If it has no seeders, then `dead?` will be true.
- **torrent** (String) The url. This should be a direct link to the torrent.
- **id** (Fixnum) An unique id for the torrent. The id is only unique for this specific torrent, not all torrents.
- **tid** (String) The `tid` method, also known as `torrent id` is a *truly* unique identifier for all torrents. It is generated using a [MD5](http://sv.wikipedia.org/wiki/MD5) with the torrent domain and the `id` method as a seed.
- **torrent_id** (String) The same as the `tid` method.
- **imdb** (String) The imdb link for the torrent, if the details view contains one. 
- **imdb_id** (String) The imdb id for the torrent, if the details view contain one. Example: tt0066026.
- **subtitle** ([Undertexter](https://github.com/oleander/Undertexter)) The subtitle for the torrent. Takes one argument, the language for the subtitle. Default is `:english`. Read more about it [here](https://github.com/oleander/Undertexter).
- **movie** ([MovieSearcher](https://github.com/oleander/MovieSearcher)) Read more about the returned object at the [MovieSearcher](https://github.com/oleander/MovieSearcher) project page.

**Note:** The `seeders`, `more`, `subtitle`, `imdb_id` and `ìmdb` method will do another request to the tracker, which means that it will take a bit longer to load then the other methods.

## How do access tracker X

Here is how to access an implemented tracker.
The first static method to apply is the name of the tracker in lower non camel cased letter.

The Pirate Bay becomes `the_pirate_bay`, TTI becomes`tti` and Torrentleech `torrentleech`.

Here is an example.

    $ Torrents.torrentleech.cookies({:my_cookie => "value"}).results 

Take a look at the [tests](https://github.com/oleander/Torrents/tree/master/spec/trackers) for all trackers to get to know more.
The test are a bit messy, I know. That is one thing that will be cleaned up in the future.

## Add you own tracker

I'm about to write a wiki that describs how to add you own site.
Until then, take a look at the parser for [The Pirate Bay](https://github.com/oleander/Torrents/blob/master/lib/torrents/trackers/the_pirate_bay.rb).

All heavy lifting has already been done, so adding another tracker should be quite easy.

I'm using [Nokogiri](http://nokogiri.org/) to parse data from the site, which in most cases means that you don't have to mess with regular expressions.

Don't know Nokogiri? Take a look at [this](http://railscasts.com/episodes/190-screen-scraping-with-nokogiri) awesome screencast by [Ryan Bates](https://github.com/ryanb).

### The short version

1. Create your own fork of the project.
2. Create and implement a tracker file inside the [tracker directory](https://github.com/oleander/Torrents/tree/master/lib/torrents/trackers).
3. Add a cached version of the tracker [here](https://github.com/oleander/Torrents/tree/master/spec/data). **Note:** Remember to remove sensitive data from the cache like username and uid.
4. Add tests for it, [here](https://github.com/oleander/Torrents/blob/master/spec/trackers/the_pirate_bay_spec.rb) is a skeleton from the Pirate Bay test class to use as a start.
5. Add the site to [this](https://github.com/oleander/Torrents/blob/master/README.md) readme.
6. Do a pull request, if you want to share you implementation with the world.

You don't have to take care about exceptions, `Torrents` does that for you.

## Disclaimer

Before you use this please be sure to get the permission from the tracker in question.
 
## How do install

    [sudo] gem install torrents
    
## How to use it in a rails 3 project

Add `gem 'torrents'` to your Gemfile and run `bundle`.

## Requirements

Torrents is tested in OS X 10.6.6 using Ruby 1.9.2.