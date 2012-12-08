require_relative 'Node.rb'
# 数値を表すノード
# number::数値
class NumberNode < Node
  def initialize(filename, line_no, number)
    super filename, line_no
    @number = number
  end
  attr :number 
  
  # 変数はスタックを用いないので0を返す
  def stack_size(scope)
    return 0
  end

  def search_function(functions)
    return nil
  end
  
  def scope_update(scope = nil, type = nil)

  end
  # 式を評価する
  # 定数なのでそのまま返す
  def expr(scope = nil)
    return number
  end

  def compile(scope = nil, type = nil)
    ret = ["PUSH #{number}"]
    return ret
  end

  def _inspect()
    return "#{number}"
  end
end



