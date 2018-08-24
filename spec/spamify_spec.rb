require 'spamify'

RSpec.describe Spamify do
  it 'has a version number' do
    expect(Spamify::VERSION).not_to be nil
  end

  it 'scrapes track ids from valid spotify track urls' do
    inputs = [
        [ 'open.spotify.com/track/3DxDNZNMA2H9hnWeblvRgL', ['3DxDNZNMA2H9hnWeblvRgL'] ],
        [ 'open.spotify.com/track/3DxDNZNMA2H9hnWeblvRgL?si=aWc4uh3sTsmwe5s86AbBlg', ['3DxDNZNMA2H9hnWeblvRgL'] ],
        [ 'open.spatify.com/track/3DxDNZNMA2H9hnWeblvRgL?si=aWc4uh3sTsmwe5s86AbBlg', [] ],
        [ 'open.spotify.com/album/3DxDNZNMA2H9hnWeblvRgL', [] ],
    ]

    inputs.each do |input|
      expect(Spamify::Spamify.scrape_id_from_uri_and_add_to_list(input[0], Spamify::Spamify::TRACKRE, [])).to(
        eq(input[1]))
    end
  end

  it 'scrapes album ids from valid spotify album urls' do
    inputs = [
        [ 'open.spotify.com/album/3DxDNZNMA2H9hnWeblvRgL', ['3DxDNZNMA2H9hnWeblvRgL'] ],
        [ 'open.spotify.com/album/3DxDNZNMA2H9hnWeblvRgL?si=aWc4uh3sTsmwe5s86AbBlg', ['3DxDNZNMA2H9hnWeblvRgL'] ],
        [ 'open.spatify.com/album/3DxDNZNMA2H9hnWeblvRgL?si=aWc4uh3sTsmwe5s86AbBlg', [] ],
        [ 'open.spotify.com/track/3DxDNZNMA2H9hnWeblvRgL', [] ],
    ]

    inputs.each do |input|
      expect(Spamify::Spamify.scrape_id_from_uri_and_add_to_list(input[0], Spamify::Spamify::ALBUMRE, [])).to(
          eq(input[1]))
    end
  end
end
