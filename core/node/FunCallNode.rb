require_relative 'Node.rb'
# 関数呼び出しを表す
# name:: 関数名
# argv:: 引数
class FunCallNode < Node
  def initialize(filename, line_no, name, argv)
    super filename, line_no
    @name = name
    @argv = argv
  end
  attr :name, :argv
  

  def expr(scope = nil)
    return :inconstant
  end
  
  def compile(scope, type)
    ret = []
    argv.each do |arg|
      ret += arg.compile(scope, type)
    end
    ret << "PUSH 127"
    ret << "PUSH 127"
    ret << "RETRIEVE"
    ret << "PUSH #{scope.stack_size}"
    ret << "ADD"
    ret << "STORE"
    
    ret << "CALL FUNCTION_#{name.upcase}"

    ret << "PUSH 127"
    ret << "PUSH 127"
    ret << "RETRIEVE"
    ret << "PUSH #{scope.stack_size}"
    ret << "SUB"
    ret << "STORE"
    return ret
  end

  def stack_size(scope = nil)
    return 0
  end

  def search_function(functions)
    if functions.contains?(name.upcase)
      functions.push name.upcase
      scope.get_function(name).search_function(functions)
    end
  end

  def scope_update(scope, type)
    argv.each do |arg|
      arg.scope_update(scope, type)
    end 
    scope.use(name)
  end
  def _inspect()
    return "#{name}(#{@argv.map(&:inspect).join(',')})"
  end
end
