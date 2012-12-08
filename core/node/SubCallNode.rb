require_relative 'Node.rb'
# 関数の呼出
class SubCallNode < Node
  def initialize(filename, line_no, name, argument_list)
    super filename, line_no
    @arguments = argument_list
    @name = name
  end
  
  attr :arguments, :name
  def compile(scope)
    ret = ""
    arguments.each do |argument|
      ret << argument.compile(scope)
    end
    
    ret <<= "CALL FUNCTION_#{name.upcase}\n"
    ret <<= "POP\n"
    return ret
  end
  def _inspect()
    ret = "Call #{@name}(#{@arguments.join(',')})"
    return ret
  end
end



