require 'slack-ruby-client'

require_relative 'credentials'

module Spamify
  class Slacker
    MAXIMUM_RETRIES = 5

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
        puts "Connected to #{@client.team.name} slack as #{@client.self.name} at #{Time.now}"
      end
      @client.on(:message){ |message| process_message(message) }
      @client.on(:closed){ |data| connection_closed(data) }
    end
  
    def process_message(message)
      begin
        puts message
  
        return if message.subtype
  
        channel = @client.channels.fetch(message.channel, nil)
        user = @client.users.fetch(message.user, nil)
        if (channel)
          puts "\nGot message on #{channel.name} with text '#{message.text}'\n"
        else
          puts "\nGot direct message from #{user.name} with text '#{message.text}'\n"
        end
  
        @spamify.process_message(message.text) do |ids|
          # add spotify reaction if message resulted in successful addition
          if ids.detect{ |key, value| !value.empty? }
            @client.web_client.reactions_add(name: 'spotify', channel: message.channel, timestamp: message.ts)
          end
        end
      rescue => error
        puts "Error: #{error}\n\t#{error.backtrace.join("\n\t")}"
      end
    end

    def connection_closed(data)
      puts "Connection closed at #{Time.now}"

      # Reset last retry timestamp if it's been over a minute
      if !@retry_timestamp || Time.now - @retry_timestamp > 60
        @retry_count = 0
      end

      unless @retry_count > MAXIMUM_RETRIES
        ++@retry_count
        @retry_timestamp = Time.now
        puts "Retrying (#{@retry_count} of #{MAXIMUM_RETRIES}) ..."
        sleep(1)
        start!
      end
    end
  
    def start!
      begin
        @client.start!
      rescue => error
        puts "Error: #{error}\n\t#{error.backtrace.join("\n\t")}"
        connection_closed(nil)
      end
    end
  end
end
