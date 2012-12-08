class DimStatementNode < Node
  def initialize(filename, line_no, nodes)
    super filename, line_no
    @nodes = nodes
  end

  attr :nodes
  
  # スコープを更新する
  def scope_update(scope, type)
    nodes.each do |node|
      node.scope_update(scope, type)
    end
  end

  # コンパイルする
  def compile(scope, type)
    res = []
    nodes.each do |node|
      res += node.compile(scope, type)
    end
    return res
  end


  def _inspect()
    return nodes.map(&:inspect).join(',')
  end
end
