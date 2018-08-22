require 'slack-ruby-client'

require_relative 'credentials'

class Slacker
  def initialize(spamify)
    @spamify = spamify
    Slack.configure do |config|
      config.token = Credentials::SLACK_BOT_API_TOKEN
    end

    Slack::RealTime::Client.configure do |config|
      # Return timestamp only for latest message object of each channel.
      config.start_options[:simple_latest] = true

      # Skip unread counts for each channel.
      config.start_options[:no_unreads] = true
    end

    @client = Slack::RealTime::Client.new
    @client.on :hello do
      puts "Connected to #{@client.team.name} slack as #{@client.self.name}"
    end
    @client.on(:message){ |message| process_message(message) }
    @client.on(:closed){ |data| puts 'Connection closed' }
  end

  def process_message(message)
    begin
      channel = @client.channels.fetch(message.channel, nil)
      if (channel)
        puts "Got message on #{channel.name}"
      end
      # if (channel && channel.name == 'talk-music')
        @spamify.process_message(message.text)
      # else
      #   puts message
      # end
    rescue => error
      puts "Error: #{error}\n\t#{error.backtrace.join("\n\t")}"
    end
  end

  def start!
    @client.start!
  end
end