require './irc'
Thread.new{ irc.start }
class BotMaster
  def initialize
    @state = {} 
  end
  
  def add_nick(nick, callback)
    nick =~ /@(.*):(.*)\.(.*).*/
    name = "#{$1}-#{$2}-#{$3}"
    @state[nick] = Irc.new(lambda{|n|}, name, callback).bot
    Thread.new{ @state[nick].start }
    @state[nick]
  end
  
  def get_bot(nick)
    @state[nick]
  end
  
end
