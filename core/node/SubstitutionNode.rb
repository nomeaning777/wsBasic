require_relative 'Node.rb'
# 変数代入を表す
# target:: 代入先の式
# node:: 代入する式
class SubstitutionNode < Node
  def initialize(filename, line_no, target, node)
    super filename, line_no
    @target = target
    @node = node
  end
  
  attr :target, :node
  def _inspect()
    return "#{target.inspect} = #{node.inspect}"
  end
end



