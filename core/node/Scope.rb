require_relative 'Node.rb'
# chBASICのスコープを表す
# data:: スコープ情報
# inner:: 現在どこに居るか
# stack_size:: 現在の関数のスタックの大きさ
# used:: 現在どこまでスタックポインタを使ったか

class Scope
  # ある名前の情報
  Data = Struct.new(:type, :data, :const)
  Variable = Struct.new(:type, :offset)
  def initialize(data = {}, inner = {:for => [], :function => [], :subroutine => []}, stack_size = 0, used = 0)
    @inner = inner
    @data = data
    @stack_size = stack_size
    @used = used
  end
  

  attr :data, :stack_size, :used, :inner
  # 変数・関数にアクセスした
  def use(name)
    data[name.upcase].const = true
  end
  # 名前をオーバーライド出来るかどうか判定する
  def update?(name)
    name = name.upcase
    return true unless data.key?(name) # まだその名前が使われていない
    return true if data[name].const == false
    return false
  end
  
  # 関数 or 変数を取得する
  def get(name)
    return data[name.upcase]
  end
  
  # 関数を取得する
  def get_function(name)
    ret = get(name)
    throw StandardError.new("#{name} is not function") unless ret.type == :function
    return ret.data
  end
  
  # 変数を取得する
  def get_variable(name)
    ret = get(name)
    throw StandardError.new("#{name} is not variable") unless ret.type == :variable
    return ret.data
  end

  # ある名前の関数or変数が存在するか
  def has?(name)
    return data.key?(name.upcase)
  end

  # nameという名の関数があるか
  def has_function?(name)
    name = name.upcase
    return data.key?(name) && data[name].type == :function
  end
  
  def has_global_variable?(name)
    name = name.upcase
    return data.key?(name) && data[name].type == :variable && data[name].data.type == :global
  end
  # グローバル変数を定義する
  def declare_global_variable(name)
    @data[name.upcase] = Data.new(:variable,
                                  Variable.new(:global, @used),
                                  true)
    @used += 1
  end

  # ローカル変数を定義する
  # [name] ローカル変数の名前
  def declare_local_variable(name)
    @data[name.upcase] = Data.new(:variable,
                                  Variable.new(:local, @used),
                                  true)
    @used += 1
  end

  # 関数を定義する
  def declare_function(name, func)
    @data[name.upcase] = Data.new(:function,
                                  func,
                                  true)
  end

  # グローバル変数全てに対する処理
  def each_global_variable()
    @data.each do |k,v|
      yield v.data if v.type == :variable && v.data.type == :global
    end
  end
  
  def each_function()
    @data.each do |k,v|
      yield v.data if v.type == :function
    end
  end
  # 一段階深い所にスコープを移動する
  # [Return]
  #   新しいスコープ
  def next_scope()
    next_data = data.clone
    next_inner = inner.clone
    next_data.each do |k,v|
      next_data[k].const = false
    end
    return Scope.new(next_data, next_inner, stack_size, used)
  end

  # 関数に入る
  def next_scope_function(func)
    ret = self.next_scope
    ret.inner[func.type].push func
    ret = Scope.new(ret.data, ret.inner, func.stack_size(self), 0)
    return ret
  end
end
