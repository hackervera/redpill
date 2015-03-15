#http://matrix.org/docs/spec/#application-service-api
#/_matrix/appservice/v1/
#http://matrix.org/blog/2015/03/02/introduction-to-application-services/
require 'restclient'

require 'json'
class MatrixApp
  def initialize(host)
    @api = "http://#{host}/_matrix/appservice/v1"
  end
  
  def register(url, token)
    resp = RestClient.post(@api+"/register", {
      url: url,
      as_token: token,
      namespaces: {
        users: [
          {
            exclusive: false,
            regex: "@irc/.*"
          }
        ],
        aliases: [
          {
            exclusive: false,
            regex: "#irc/.*"
          }
        ]
      }
    }.to_json)
    
  end
  
end
