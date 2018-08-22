require 'rspotify'

require_relative 'credentials'

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

  def add_tracks_by_id(track_ids)
    add_tracks(RSpotify::Track.find(track_ids))
  end

  def add_albums_by_id(album_ids)
    albums = RSpotify::Album.find(album_ids)
    tracks = if albums.is_a? Array
               albums.inject([]){ |tracks, album| tracks + album.tracks }
             else
               album.tracks
             end
    add_tracks(tracks)
  end

  def add_tracks(tracks)
    @playlist.add_tracks!(tracks)
  end
end

