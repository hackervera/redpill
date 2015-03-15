require 'cinch'
require 'yaml'
class Irc
  attr_accessor :bot
  def initialize(callback)
    config = YAML.load_file('config.yaml')
    @bot = Cinch::Bot.new do
      configure do |c|
        c.server = config["bot_server"]
        c.nick = config["bot_name"]
      end

      on :message do |m|
        callback.call(m)
      end
      
      on :connect do
        channels = config["channel_map"].map{|c| c["irc_channel"]}
        channels.each{|c| @bot.join(c) }
      end
    end
  end

  def start
    @bot.start
  end
  
  def stop
    @bot.stop
  end
end
