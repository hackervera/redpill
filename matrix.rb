require 'restclient'
require 'json'
class Matrix
  def initialize(host)
    @api = "http://#{host}/_matrix/client/api/v1"
  end
  
  def login(user, pass)
    resp = RestClient.post(@api+"/login", {
      type: "m.login.password",
      user: user,
      password: pass
    }.to_json)
    
    JSON.parse(resp)["access_token"]
  end
  
  def send_message(channel, message, token, user_id=nil)    
    extra = user_id ? "&user_id=#{user_id}" : "" 
    RestClient.post(@api+"/rooms/#{channel}/send/m.room.message?access_token=#{token}"+extra, {
      body: message,
      msgtype: "m.text"
    }.to_json)
  end
  
  def room_id(room_alias, token)
    res = RestClient.get(@api+"/directory/room/#{CGI.escape(room_alias)}?access_token=#{token}")
    JSON.parse(res)["room_id"]
  end
  
  def join(channel, token, user_id=nil)
    extra = user_id ? "&user_id=#{user_id}" : ""
    RestClient.post(@api+"/rooms/#{channel}/join?access_token=#{token}"+extra, {}.to_json)
  end
  
  def alias(channel, token)
    res = RestClient.get(@api+"/rooms/#{channel}/state?access_token=#{token}")
    JSON.parse(res).detect{|r| r["type"] == "m.room.aliases"}["content"]["aliases"].last
  end
  
  def name(channel, token)
    res = RestClient.get(@api+"/rooms/#{channel}/state/m.room.name?access_token=#{token}")
    JSON.parse(res)["name"]
  end
end
