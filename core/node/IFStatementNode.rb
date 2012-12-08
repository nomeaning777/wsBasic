require_relative 'Node.rb'
class IFStatementNode < Node
  def initialize(filename, line_no, condition, then_block, else_block)
    super filename, line_no
    @condition = condition
    @then_block = then_block
    @else_block = else_block
  end
  
  attr :condition, :then_block, :else_block
  
  def search_function(functions)
    left.search_function(functions)
    right.search_function(functions)
    return nil
  end
  # TODO 実装する
  def stack_size(scope)
    return 0
  end

  # TODO 実装する
  def scope_update(scope, type)
  
  end

  def compile(scope, type)
    ret = condition.compile(scope, type)
    l1, l2 = get_label(), get_label()
    ret << "JUMPIFZERO #{l2}"
    ret += compile_block(then_block, scope ,type)  # TRUE
    ret << "JUMP #{l1}"
    
    ret << "LABEL #{l2}"
    # ELSE
    ret += compile_block(else_block, scope ,type)  # FALSE 
    ret << "LABEL #{l1}"
    
    return ret
  end

  def _inspect()
    return "#{condition.inspect} ? #{then_block.map(&:inspect).join(',')} : #{else_block.map(&:inspect).join(',')}"
  end
end



