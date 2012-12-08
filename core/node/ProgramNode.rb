class ProgramNode < Node
  def initialize(filename, line_no, nodes)
    super filename, line_no
    @nodes = nodes
  end

  attr :nodes
  # プログラムをコンパイルします
  def compile(initial_function = :Main)
    scope = Scope.new({},{:for => [], :function => [], :subroutine => []} , 0, 128) # スコープの作成
    
    nodes.each do |node|
      node.scope_update scope, :global # グローバルなスコープの作成
    end
    
    # Main関数があるかどうか
    unless scope.has_function?(initial_function)
      compile_error!("Not Found #{initial_function} Function")
    end

    # Main関数から呼び出されている関数一覧を取得する
    # TODO 正しいものを作成する
    functions = []
    scope.each_function do |f|
      functions << f.name
    end
    # functions = [initial_function.upcase]
    # scope.get_function(initial_function).search_function(functions)

    ret = []
    # スタックポインタを128に
    ret << "PUSH 127"
    ret << "PUSH #{scope.used}"
    ret << "STORE"

    # グローバル変数の初期化
    nodes.each do |node|
      ret += node.compile(scope, :global)
    end
    
    ret << "JUMP ENTRYPOINT"

    # 関数の宣言
    functions.each do |function|
      next unless scope.has_function?(function)
      func = scope.get_function(function)
      ret += func.compile(scope.next_scope_function(func), :function)
    end

    ret << "LABEL ENTRYPOINT"
    # 引数の初期化
    scope.get_function(initial_function).argv.count.times do
      ret << "PUSH 0"
    end

    ret << "CALL FUNCTION_#{initial_function.upcase}" # メイン関数を呼び出す
    ret << "POP"
    ret << "END"

    return ret
  end

  def _inspect()
    return nodes.map(&:inspect).join(',')
  end
end
