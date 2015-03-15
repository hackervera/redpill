require 'sinatra/base'
require 'json'
require './irc'
require './matrix'
require 'yaml'
require './bot_master'
require 'pry'

class Webserver < Sinatra::Base
  set :bind, '0.0.0.0'
  
  config = YAML.load_file('config.yaml')
  matrix = Matrix.new(config["host"])
  token = matrix.login(config["user"], config["password"])
  callback = lambda do |m|
    channel_name = m.channel.name
    matrix_channel = config["channel_map"].detect{|c| c["irc_channel"] == channel_name}["matrix_channel"]
    nick = m.user.nick
    host = matrix_channel.split(":").last
    user = "@irc/#{nick}:#{host}"
    room_id = matrix.room_id(matrix_channel, token)
    unless user =~ /-relay/
      matrix.join(room_id, config["app_password"], user)
      matrix.send_message(room_id, m.message, config["app_password"], user)
    end
  end
  irc = Irc.new(callback)
  Thread.new{ irc.start }
  bot_master = BotMaster.new
  
  def in_channel?(irc, channel_name)
    irc.bot.channels.detect{|c| c == channel_name}
  end
    
  put "/transactions/:transaction" do
    config = YAML.load_file('config.yaml')
    events = JSON.parse(request.body.read)["events"]
    puts events
    data = events.first
    return {}.to_json unless data["type"] == "m.room.message"
    message = data["content"]["body"]
    nick = data["user_id"]
    clean_nick = nick.split(":")
    host = data["room_id"].split(":").last
    room_alias = matrix.alias(data["room_id"], token)
    irc_channel = config["channel_map"].detect{|c| c["matrix_channel"] == room_alias}["irc_channel"]
    
    if nick !~ /irc/
      bot = bot_master.get_bot(nick)
      if bot
        channel = bot.Channel(irc_channel)
        if in_channel?(bot, channel.name)
          channel.send(message)
        else
          bot.join(irc_channel)
          channel.send(message)
        end
      else
        callback = lambda{|bot|
          channel = bot.Channel(irc_channel)
          bot.join irc_channel
          channel.send(message)
        }
        bot_master.add_nick(nick, callback)
      end
    end
    {}.to_json
  end
  

  run!
end
    
