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
    channel = m.channel.name.gsub("#","#irc/")
    nick = m.user.nick
    host = channel.split(":").last
    user = "@irc/#{nick}:#{host}"
    room_id = matrix.room_id(channel, token)
    matrix.join(room_id, config["app_password"], user)
    matrix.send_message(room_id, m.message, config["app_password"], user)
  end
  irc = Irc.new(callback)
  Thread.new{ irc.start }
  
  def in_channel?(irc, channel_name)
    irc.bot.channels.detect{|c| c == channel_name}
  end
    
  put "/transactions/:transaction" do
    events = JSON.parse(request.body.read)["events"]
    puts events
    data = events.first
    message = data["content"]["body"]
    nick = data["user_id"]
    host = data["room_id"].split(":").last
    room_alias = matrix.alias(data["room_id"], token).split("/").last
    channel = irc.bot.Channel("#"+room_alias)
    if in_channel?(irc, channel.name)
      channel.send("#{nick}: #{message}") unless nick =~ /irc/
    else
      irc.bot.join("#"+room_alias)
      channel.send("#{nick}: #{message}") unless nick =~ /irc/
    end
    {}.to_json
  end
  

  run!
end
    
