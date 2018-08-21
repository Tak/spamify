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

  def add_tracks(tracks)
    @playlist.add_tracks!(RSpotify::Track.find(tracks))
  end
end

