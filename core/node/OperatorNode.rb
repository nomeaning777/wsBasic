require_relative 'Node.rb'
class OperatorNode < Node
  def initialize(filename, line_no, left, right, vm, &func)
    super filename, line_no
    @left = left
    @right = right
    @vm = vm
    @func = func
  end
  
  attr :left, :right, :vm
  
  def search_function(functions)
    left.search_function(functions)
    right.search_function(functions)
    return nil
  end
  
  def stack_size(scope)
    l = left.stack_size(scope)
    r = right.stack_size(scope)
    return l + r
  end

  # コンパイル時評価
  def expr(scope)
    l = left.expr(scope)
    r = right.expr(scope)
    if l.is_a?(Integer) && r.is_a?(Integer)
      return @func.call(l, r)
    end
    return :inconstant
  end

  def scope_update(scope, type)
    left.scope_update(scope, type)
    right.scope_update(scope, type)
  end

  def compile(scope, type)
    value = self.expr(scope)
    if value.is_a?(Integer)
      ret = ["PUSH #{value}"]
    else
      ret = []
      ret += left.compile(scope, type)
      ret += right.compile(scope, type)
      ret += convert_label(vm)
    end
    return ret
  end
  def _inspect()
    return "#{left.inspect},#{right.inspect},#{vm.map(&:inspect).join(',')}"
  end

private
  def convert_label(vm)
    ret = []
    l = {}
    vm.each do |cmd|
      if /LABEL_(.+)/ =~ cmd
        unless l.key?($1)
          l[$1] = get_label
        end
        cmd = cmd.gsub(/LABEL_(.+)/, l[$1])
      end
      ret << cmd
    end
    return ret
  end
end



