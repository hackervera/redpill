require 'sinatra/base'
require 'json'
require './irc'
require './matrix'
require 'yaml'

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
    matrix.join(room_id, config["app_password"], user)
    matrix.send_message(room_id, m.message, config["app_password"], user)
  end
  irc = Irc.new(callback)
  Thread.new{ irc.start }
  
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
    host = data["room_id"].split(":").last
    room_alias = matrix.alias(data["room_id"], token)
    irc_channel = config["channel_map"].detect{|c| c["matrix_channel"] == room_alias}["irc_channel"]
    channel = irc.bot.Channel(irc_channel)
    if in_channel?(irc, channel.name)
      channel.send("#{nick}: #{message}") unless nick =~ /irc/
    else
      irc.bot.join(irc_channel)
      channel.send("#{nick}: #{message}") unless nick =~ /irc/
    end
    {}.to_json
  end
  

  run!
end
    
