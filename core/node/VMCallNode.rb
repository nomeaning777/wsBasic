require_relative 'Node.rb'
# VMの命令を直接記述する
class VMCallNode < Node
  def initialize(filename, line_no, cmd)
    super filename, line_no
    @cmd = cmd
  end

  attr :cmd
  
  def stack_size(scope = nil)
    return 0
  end
  
  def search_function(functions)
    return nil
  end
  
  # スコープは弄らないので何もしない
  def scope_update(scope = nil, type = nil)
    return nil
  end

  def compile(scope = nil, type = nil)
    return ["#{@cmd}"]
  end

  def _inspect()
    ret = "#{@cmd}"
    return ret
  end
end



