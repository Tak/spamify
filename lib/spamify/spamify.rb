#!/usr/bin/ruby

require 'urika'
require 'spamify/spotify'
require 'spamify/slacker'

module Spamify
  class Spamify
    TRACKRE = /^open.spotify.com\/track\/(\w+).*$/
    ALBUMRE = /^open.spotify.com\/album\/(\w+).*$/
  
    def initialize
      # Initialize spotify
      @spotify = Spotify.new()
      @slack = Slacker.new(self)
    end
  
    def process_message(message)
      urls = Urika.get_all_urls(message)
      ids = { tracks: [], albums: [] }

      ids = {
          tracks: urls.inject([]){ |list, url| list + Spamify.scrape_id_from_uri(url, TRACKRE) },
          albums: urls.inject([]){ |list, url| list + Spamify.scrape_id_from_uri(url, ALBUMRE) },
      }

      @spotify.add_to_playlist_by_id(ids)
      yield(ids)
    end
  
    def self.scrape_id_from_uri(url, pattern)
      match = url.match(pattern)
      if match && !match.captures.empty?
        [match.captures[0]]
      else
        []
      end
    end
  
    def start!
      @slack.start!
    end
  end
end
