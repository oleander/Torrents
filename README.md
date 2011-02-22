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

### The results method

As soon as you apply the `results` method on the query it will try to execute your request.

It will return a list of `Container::Torrent` object is the request was sucessfull, otherwise it will return an empty list.

### The Container::Torrent class

It has some nice accessors that might be useful.

- **title** (String) Title of the torrent.
- **details** (String) The url to the details page for the torrent.
- **seeders** (Fixnum) The amount of seeders for the torrent. **Note:** See the *seeders* method.
- **dead?** (Boolean) Check to see if the torrent has no seeders. If it has no seeders, then `dead?` will be true. **Note:** See the *seeders* method.
- **torrent** (String) The url to the torrent. This should be a direct link to the torrent.
- **id** (Fixnum) An unique id for the torrent. The id is only unique for this specific torrent, not all torrents.
- **tid** (String) The `tid` method, also known as `torrent id` is a *truly* unique identifier for all torrents. It is generated using a [MD5](http://sv.wikipedia.org/wiki/MD5) with the torrent domain and the `id` method as a seed.
- **torrent_id** (String) The same as the `tid` method.
- **imdb** (String) The imdb link for the torrent, if the details view contains one. 
- **imdb_id** (String) The imdb id for the torrent, if the details view contain one. Example: tt0066026.
- **subtitle** ([Undertexter](https://github.com/oleander/Undertexter)) The subtitle for the torrent. Takes one argument, the language for the subtitle. Default is `:english`.
- **movie** ([MovieSearcher](https://github.com/oleander/MovieSearcher)) Read more about the returned object at the [MovieSearcher](https://github.com/oleander/MovieSearcher) project page.

**Note:** The `seeders`, `more`, `subtitle`, `imdb_id` and `ìmdb` will do another request to the tracker, which means that it will take a bit longer to load then the other methods.

### The find_by_details method

If you have access to a single details link and want to get some useful data from it then `find_by_details` might solve you problem.

The method takes the url as an argument and returnes a single `Container::Torrent` object.

    $ Torrents.the_pirate_bay.find_by_details("http://thepiratebay.org/torrent/6173093/")

## How do install

    [sudo] gem install torrents
    
## How to use it in a rails 3 project

Add `gem 'torrents'` to your Gemfile and run `bundle`.

## Requirements

Torrents is tested in OS X 10.6.6 using Ruby 1.9.2.