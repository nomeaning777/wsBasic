require_relative 'Node.rb'
# 関数
# name:: 関数名
# argv:: 引数
# nodes:: 命令
# type:: サブルーチン(:subroutine)か関数(:function)
class FunctionNode < Node
  def initialize(filename, line_no, name, argv, nodes, type)
    super filename, line_no
    @name, @argv, @nodes, @type = name, argv, nodes, type
  end

  attr :name, :nodes, :argv, :type
  # 関数の定義をスコープに書き込む
  def scope_update(scope, type)
    throw StandardError.new('Cannot make local function') unless type == :global
    
    unless scope.update?(name)
      compile_error!("\"#{name}\" is already declared")
    end

    scope.declare_function(name, self)
  end
  
  # 呼び出されている関数を検索する
  def search_function(functions)
    nodes.each do |node|
      node.search_function functions
    end
  end
  
  # コンパイル
  def compile(scope = nil, type)
    if type == :global
      return []
    elsif type == :function
      ret = []
      ret << "LABEL FUNCTION_#{name.upcase}"
      # 初期化
      scope.declare_local_variable(:__return)
      ret << "PUSH 127"
      ret << "RETRIEVE" # sp取得
      ret << "PUSH #{scope.get_variable(:__return).offset}"
      ret << "ADD"
      ret << "PUSH 0"
      ret << "STORE"
      
      # 引数取得
      argv.reverse.each do |var|
        unless scope.update?(var)
          compile_error! "#{var} is already defined"
        end
        scope.declare_local_variable(var)
        ret << "PUSH 127"
        ret << "RETRIEVE" # sp取得
        ret << "PUSH #{scope.get_variable(var).offset}"
        ret << "ADD"
        ret << "SWAP"
        ret << "STORE"
      end
      # ひたすら進めていく
      nodes.each do |node|
        node.scope_update(scope, type)
        ret += node.compile(scope, type) 
      end
      # 終了前
      if @type == :subroutine
        ret << "PUSH 0"
      elsif @type == :function
        ret << "PUSH 127"
        ret << "RETRIEVE" # sp取得
        ret << "PUSH #{scope.get_variable(:__return).offset}"
        ret << "ADD"
        ret << "RETRIEVE"
      end
      ret << "RET"
      return ret
    end
  end
  
  # 必要なスタック容量の計算
  def stack_size(scope)
    return ([0] + nodes.map{|v| v.stack_size(scope)}).inject(:+) + 1 + argv.size()
  end
  def _inspect()
    return "#{type} #{name}(#{argv.join(',')}) {#{nodes.map(&:inspect).join(',')}}"
  end
end
