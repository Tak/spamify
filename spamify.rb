#!/usr/bin/ruby

require_relative 'urika'
require_relative 'spotify'

class Spamify
  TRACKRE = /^open.spotify.com\/track\/(\w+).*$/

  def initialize
    # Initialize spotify
    @spotify = Spotify.new()
  end

  def process_message(message)
    tracks = Urika.get_all_urls(message).inject([]) do |memo, url|
      track_id = Spamify.scrape_track_id_from_uri(url)
      track_id ? memo << track_id : memo
    end

    add_to_playlist(tracks) if (!tracks.empty?)
  end

  def self.scrape_track_id_from_uri(uri)
    match = uri.match(TRACKRE)
    if match && !match.captures.empty?
      match.captures[0]
    else
      nil
    end
  end

  def add_to_playlist(tracks)
    @spotify.add_tracks(tracks)
  end
end

if (__FILE__ == $0)
  require 'test/unit'

  class SpamifyTest < Test::Unit::TestCase
    def setup()
    end # setup

    def test_scrape_track_id_from_uri
      inputs = [
          [ 'open.spotify.com/track/3DxDNZNMA2H9hnWeblvRgL', '3DxDNZNMA2H9hnWeblvRgL' ],
          [ 'open.spotify.com/track/3DxDNZNMA2H9hnWeblvRgL?si=aWc4uh3sTsmwe5s86AbBlg', '3DxDNZNMA2H9hnWeblvRgL' ],
          [ 'open.spatify.com/track/3DxDNZNMA2H9hnWeblvRgL?si=aWc4uh3sTsmwe5s86AbBlg', nil ],
      ]

      inputs.each do |input|
        assert_equal(input[1], Spamify.scrape_track_id_from_uri(input[0]), "Incorrect scrape of #{input[0]}")
      end
    end
  end

  unless ARGV.empty?
    spamify = Spamify.new()
    spamify.process_message(ARGV[0])
  end
end
