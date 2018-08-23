#!/usr/bin/ruby

require_relative 'urika'
require_relative 'spotify'
require_relative 'slacker'

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

if (__FILE__ == $0)
  require 'test/unit'

  class SpamifyTest < Test::Unit::TestCase
    def setup()
    end # setup

    def test_scrape_track_id_from_uri
      inputs = [
          [ 'open.spotify.com/track/3DxDNZNMA2H9hnWeblvRgL', ['3DxDNZNMA2H9hnWeblvRgL'] ],
          [ 'open.spotify.com/track/3DxDNZNMA2H9hnWeblvRgL?si=aWc4uh3sTsmwe5s86AbBlg', ['3DxDNZNMA2H9hnWeblvRgL'] ],
          [ 'open.spatify.com/track/3DxDNZNMA2H9hnWeblvRgL?si=aWc4uh3sTsmwe5s86AbBlg', [] ],
      ]

      inputs.each do |input|
        assert_equal(input[1], Spamify.scrape_id_from_uri_and_add_to_list(input[0], Spamify::TRACKRE, []), "Incorrect scrape of #{input[0]}")
      end
    end

    def test_scrape_album_id_from_uri
      inputs = [
          [ 'open.spotify.com/album/3DxDNZNMA2H9hnWeblvRgL', ['3DxDNZNMA2H9hnWeblvRgL'] ],
          [ 'open.spotify.com/album/3DxDNZNMA2H9hnWeblvRgL?si=aWc4uh3sTsmwe5s86AbBlg', ['3DxDNZNMA2H9hnWeblvRgL'] ],
          [ 'open.spatify.com/album/3DxDNZNMA2H9hnWeblvRgL?si=aWc4uh3sTsmwe5s86AbBlg', [] ],
      ]

      inputs.each do |input|
        assert_equal(input[1], Spamify.scrape_id_from_uri_and_add_to_list(input[0], Spamify::ALBUMRE, []), "Incorrect scrape of #{input[0]}")
      end
    end
  end

  spamify = Spamify.new()
  spamify.start!
end
