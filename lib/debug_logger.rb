
# Defines some common logging functions for libraries.
# Contains a class variable called @modes, which represents
# the available verbosities:
#
#   DebugLogger::modes[:silent]
#   DebugLogger::modes[:debug]
#   DebugLogger::modes[:production]
class DebugLogger
  attr_accessor :mode
  class << self
    attr_accessor :modes
  end
  @modes =  {:silent => 0, :debug => 1, :production => 2}

  # Params:
  # [mode] Which mode to operate in.  This should correspond
  #        to one of the class variable @modes
  # [id]   An optional string to print before each message.
  #        This is commonly the id of the instantiating class.
  def initialize(mode, id="")
    #@modes_str = {0 => "", 1=>"D",2=>"P"}
    @mode = mode
    @id = id
  end

  # If the mode is set to :debug, then it will print
  # out the given string with a debug prefix
  def dbg_log(str)
    if @mode != DebugLogger.modes[:debug]
      return
    end

    if @id.eql?("")
      puts("[D] #{str}")
    else
      puts("[D] [#{@id}] #{str}")
    end
  end
end
