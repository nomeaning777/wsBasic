class VariableDeclarationNode < Node
  def initialize(filename, line_no, name, expr)
    super filename, line_no
    @name = name
    @expr = expr
  end

  attr :name, :expr
  
  def scope_update(scope, type)
    value = expr.expr(scope)
    if type == :global
      unless value.instance_of?(Fixnum) || value.instance_of?(Bignum) # 定数じゃない場合数字が決定しない！
        compile_error! "Global variable must be initialized on constance"
      end

      unless scope.update?(name)
        compile_error! "\"#{name}\" is alreay declared"
      end
      
      scope.declare_global_variable(name)
    else
      throw StandardError.new('Not Implemented')
    end
  end
  
  def compile(scope, type = :local)
    
    ret = []
    if type == :global
      var = scope.get_variable(name)
      ret << "PUSH #{var.offset}"
      ret << "PUSH #{expr.expr(scope)}"
      ret << "STORE"
      return ret
    end
  end

  def _inspect()
    return "#{name} = #{expr.inspect}"
  end
end
