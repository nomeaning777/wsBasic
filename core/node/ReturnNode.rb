require_relative 'Node.rb'
# プログラム全体
class ReturnNode < Node
  def initialize(filename, line_no, expr)
    super filename, line_no
    @expr = expr
  end

  attr :expr

  def stack_size(scope = nil)
    return expr.stack_size(scope)
  end
  
  def search_function(functions)
    return expr.search_function(functions)
  end
  
  def scope_update(scope = nil, type = nil)
    expr.scope_update(scope, type)
  end

  def compile(scope = nil, type = nil)
    ret = expr.compile(scope, type = nil)
    ret << 'RET'
    return ret
  end

  def _inspect()
    ret = "#{expr}"
    return ret
  end
end



