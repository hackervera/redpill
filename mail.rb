require './mail'
require 'mini-smtp-server'
class Mail < MiniSmtpServer
  def new_message_event(message_hash)
    puts "# New email received:"
    puts "-- From: #{message_hash[:from]}"
    puts "-- To:   #{message_hash[:to]}"
    puts "--"
    puts "-- " + message_hash[:data].gsub(/\r\n/, "\r\n-- ")
    puts
  end
end
server = Mail.new(25, "0.0.0.0", 4)
server.start
server.join
