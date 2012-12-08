require_relative 'Scope.rb'

# コンパイル中に発生したエラー
class CompileError < StandardError
end
# 構文解析及びコンパイルで用いるノードの継承元
class Node
  
  def initialize(filename, line_no)
    @filename = filename
    @line_no = line_no
  end
  attr :filename, :line_no
  
  # ノードをコンパイルし、結果を返す
  # [Return]
  #   文字列の配列が返される
  def compile(scope = nil)
    raise Exception.new('Not Implemented')
  end

  # スコープを更新する
  def scope_update(scope = nil, scope_type = :local)
    raise Exception.new('Not Implemented')
  end
  
  # 評価する
  # 代入可能な式の場合は:substitutableを返し、さらにsubstitutionメソッドを実装する必要がある
  # 定数式の場合は整数、そうでない場合は:inconstatntを返す
  def expr(scope = nil)
    raise Exception.new('Not Implemented')
  end
  
  # 変数代入処理を記述する
  def substitution(scope = nil)
    raise Exception.new('Not Implemented')
  end

  # 利用するスタックの大きさを求める
  def stack_size(scope = nil)
    raise Exception.new('Not Implemented')
  end
  
  # 以下にある関数呼び出しを全て調べ、functions(ハッシュ)に代入する
  def search_function(functions)
    raise Exception.new('Not Implemented')
  end
  # コンパイル時のエラーについて一括で処理する
  def compile_error!(msg)
    STDERR.puts "Error: In #{@filename}:#{@line_no}: #{msg}"
    raise CompileError.new("Compile Error: In #{@filename}:#{@line_no}: #{msg}")
  end
  
  def compile_block(block, scope, type)
    ([[]] + block.map{|v| v.compile(scope,type)}).inject(:+)
  end

  def inspect
    return "<#{self.class.name}:#{filename}:#{@line_no}>( #{self._inspect} )"
  end

  def _inspect
    return ""
  end

  # 重複しないラベル名を取得する
  def get_label()
    @@used_label ||= 1
    @@used_label += 1
    return "tmp_label_#{@@used_label - 1}"
  end
end
