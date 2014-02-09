

class DebugLogger
  attr_accessor :mode
  class << self
    attr_accessor :modes
  end
  @modes =  {:silent => 0, :debug => 1, :production => 2}

  def initialize(mode, id="")
    #@modes_str = {0 => "", 1=>"D",2=>"P"}
    @mode = mode
    @id = id
  end

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
