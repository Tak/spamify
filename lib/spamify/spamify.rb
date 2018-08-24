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
      tracks = []
      albums = []
  
      urls.each do |url|
        Spamify.scrape_id_from_uri_and_add_to_list(url, TRACKRE, tracks)
        Spamify.scrape_id_from_uri_and_add_to_list(url, ALBUMRE, albums)
      end
  
      add_tracks_to_playlist(tracks) if (!tracks.empty?)
      add_albums_to_playlist(albums) if (!albums.empty?)
  
      !tracks.empty? || !albums.empty?
    end
  
    def self.scrape_id_from_uri_and_add_to_list(url, pattern, list)
      match = url.match(pattern)
      if match && !match.captures.empty?
        list << match.captures[0]
      else
        list
      end
    end
  
    def add_tracks_to_playlist(tracks)
      @spotify.add_tracks_by_id(tracks)
    end
  
    def add_albums_to_playlist(albums)
      @spotify.add_albums_by_id(albums)
    end
  
    def start!
      @slack.start!
    end
  end
end
