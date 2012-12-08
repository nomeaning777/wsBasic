require_relative 'Node.rb'
# 定数定義
# name:: 定数名
# expr:: 定数の内容のノード
class ConstantDeclarationNode < Node
  def initialize(filename, line_no, name, expr)
    super filename, line_no
    @name = name
    @expr = expr
  end

  attr :name, :expr
  
  def _inspect()
    return "const #{name} = #{expr.inspect}"
  end
end
