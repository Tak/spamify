require 'rspotify'

require_relative 'credentials'

module Spamify
  class Spotify
    def initialize
      begin
        RSpotify.authenticate(Credentials::SPOTIFY_CLIENT_ID, Credentials::SPOTIFY_CLIENT_SECRET)
        @user = RSpotify::User.new(Credentials::SPOTIFY_TOKEN_RESPONSE)
        @playlist = RSpotify::Playlist.find(Credentials::SPOTIFY_USER_ID, Credentials::SPOTIFY_PLAYLIST_ID)
      # rescue => error
      #   puts "Error authenticating with Spotify: #{error.to_s}\n#{error.backtrace}"
      end
    end

    def add_to_playlist_by_id(ids)
      add_tracks(get_tracks_by_track_id(ids[:tracks]) +
        get_tracks_by_album_id(ids[:albums]))
    end

    def get_tracks_by_track_id(track_ids)
      track_ids.empty? ? [] : RSpotify::Track.find(track_ids)
    end
  
    def get_tracks_by_album_id(album_ids)
      return [] if album_ids.empty?

      albums = RSpotify::Album.find(album_ids)
      if albums.is_a? Array
        albums.inject([]){ |tracks, album| tracks + album.tracks }
      else
        album.tracks
      end
    end
  
    def add_tracks(tracks)
      for i in 1..3
        begin
          @playlist.add_tracks!(tracks) unless tracks.empty?
          return
        rescue => error
          puts "Adding tracks failed: #{error}"
          sleep(1)
        end
        puts 'Retrying...'
      end
      puts 'Failed to add tracks'
    end
  end
end
