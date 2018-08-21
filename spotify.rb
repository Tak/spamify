require 'rspotify'

require_relative 'credentials'

class Spotify
  def initialize
    begin
      RSpotify.authenticate(Credentials::CLIENT_ID, Credentials::CLIENT_SECRET)
      @user = RSpotify::User.new(Credentials::TOKEN_RESPONSE)
      @playlist = RSpotify::Playlist.find(Credentials::USER_ID, Credentials::PLAYLIST_ID)
    # rescue => error
    #   puts "Error authenticating with Spotify: #{error.to_s}\n#{error.backtrace}"
    end
  end

  def add_tracks(tracks)
    @playlist.add_tracks!(RSpotify::Track.find(tracks))
  end
end

