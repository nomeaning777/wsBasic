require_relative 'Node.rb'
require_relative 'FunCallNode.rb'
# 変数を表す
# 場合によっては関数呼び出しになることに注意
# name:: 変数名
class VariableNode < Node
  def initialize(filename, line_no, name)
    super filename, line_no
    @name = name
  end
  
  attr :name

  def expr(scope = nil)
    return :substitutable
  end
  
  def scope_update(scope, type)
    unless scope.has?(name)
      compile_error!("Undefined Variable #{name}")
    end
    if scope.has_function?(name)
      return FunCallNode.new(@filename, @line_no, @name, []).scope_update(scope, type)
    end
    scope.use(name)
  end
  
  def search_function(scope, functions)
    # 関数候補に追加
    unless functions.include?(name)
      functions.push name
    end
  end

  def stack_size(scope)
    return 0
  end
  

  def compile(scope, type)
    ret = []
    if scope.has_function?(name)
      return FunCallNode.new(@filename, @line_no, @name ,[]).compile(scope, type)
    end
    var = scope.get_variable(name)
    if var.type == :local
      ret << "PUSH 127"
      ret << "RETRIEVE"
      ret << "PUSH #{var.offset}"
      ret << "ADD"
      ret << "RETRIEVE"
    else
      ret << "PUSH #{var.offset}"
      ret << "RETRIEVE"
    end
    return ret
  end

  def _inspect()
    return "#{name}"
  end
end



