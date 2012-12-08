# == VM
# chBASICで用いる仮想マシン

class VM

public
  # プログラム実行中に起きたエラー
  class ProgramError < StandardError
  end

  # 解析中に起きたエラー
  class AnalyzeError < StandardError
  end

  # VMを初期化する
  # [options]
  #   VMのオプション
  #   [\:ignore_analyze_error] 解析時のエラーを無視する。無視しない場合はStandardError例外が出る
  #   [\:ignore_error] 実行時のエラーがあっても継続する
  #   [\:show_error] 実行時のエラーを表示する
  #   [\:raise] 実行時に例外を出す
  def initialize(options = {:ignore_analyze_error => true, :show_error => true})
    @heap = Hash.new
    @heap.default = 0
    @label = Hash.new
    @stack = Array.new
    @getchar = ""

    @options = options
    @options.default = false
  end
  
  # プログラムを実行する
  # [program]
  #   VMで実行するプログラム(Array)
  def run(program)
    program = analyze(program)
    run_analyzed program
  end
  
  # プログラムを解析する
  # [program]
  #   解析対象のプログラム
  # [Return]
  #   解析結果(配列で与えられる)
  def analyze(program)
    set_program program
    return get_program
  end
  
  # 解析されたプログラムを実行する
  # [program]
  #   解析済みのプログラム（analyzeメソッドで作成する）
  def run_analyzed(program)
    get_labels program
    run_program program
  end
private
  # エラーを出す
  def raise_error(error_message, from = nil)
    if @options[:show_error]
      STDERR.puts "VM Error: #{error_message}" + (from ? " on #{from}" : "")
    end

    unless @options[:ignore_error]
      raise ProgramError.new(error_message)
    end
  end

  # 一文字取得する
  # EOFの場合-1を返す（独自拡張）
  def getchar()
    if @getchar == nil
      return -1
    end
    while @getchar == ""
      @getchar = STDIN.gets
      if @getchar == nil
        return -1
      end
    end
    ret = @getchar[0].ord
    @getchar = @getchar.slice(1, @getchar.size() - 1)
    return ret
  end
  
  # 空白を読み飛す
  def skipspace()
    while true
      w = getchar()
      if w == ' ' || w == '\n' || w == '\t' || w == '\r'
        next
      end
      @getchar = w.chr('UTF-8') + @getchar
      break
    end
  end

  # 一数字取得する（独自拡張で空白区切りとなる。実際には改行区切り）
  def getint()
    skipspace
    w = getchar()
    sign = 1
    ret = 0
    if w == '-'.ord
      sign = -1
    elsif w >= 48 && w < 58
      ret = w - 48
    else
      raise_error 'Parse Error', 'GETINT'
    end

    while true
      w = getchar()
      if 48 <= w && w < 58
        ret = ret * 10 + w - 48
      else
        break
      end
    end
  end

  # プログラムを実行する
  # [program]
  #  解析ずみのプログラム
  def run_program(program)
    p = 0
    call = [] # 呼び出し元スタック
    begin
      while program[p]
        case program[p][0]
        when :PUSH
          @stack.push program[p][1]
        when :DUP
          raise_error 'Stack is Empty','DUP' if @stack.size() == 0
          tmp = @stack.pop()
          @stack.push tmp
          @stack.push tmp
        when :COPY
          raise_error 'Invalid Parameter', 'COPY' if @stack.size() <= program[p][1]
          @stack.push @stack[@stack.size() - 1 - program[p][1]]
        when :SWAP
          raise_error 'Stack Size Less than 2','SWAP' if @stack.size() <= 1
          @stack[@stack.size()-1], @stack[@stack.size()-2] =
            @stack[@stack.size()-2], @stack[@stack.size()-1]
        when :POP
          raise_error 'Stack is Empty','POP' if @stack.size() == 0
          @stack.pop
        when :SLIDE
          if program[p][1] > 0
            raise_error 'Invalid Parameter', 'SLIDE' unless @stack.size() >= program[p][1] + 1
            top = @stack.pop
            program[p][1].times { @stack.pop }
            @stack.push top
          end
        when :ADD
          raise_error 'Stack Size Less than 2','ADD' if @stack.size() <= 1
          top1 = @stack.pop
          top2 = @stack.pop
          @stack.push top2 + top1
        when :SUB
          raise_error 'Stack Size Less than 2','SUB' if @stack.size() <= 1
          top1 = @stack.pop
          top2 = @stack.pop
          @stack.push top2 - top1
        when :MUL
          raise_error 'Stack Size Less than 2','MUL' if @stack.size() <= 1
          top1 = @stack.pop
          top2 = @stack.pop
          @stack.push top2 * top1
        when :DIV
          raise_error 'Stack Size Less than 2','DIV' if @stack.size() <= 1
          top1 = @stack.pop
          top2 = @stack.pop
          @stack.push top2 / top1
        when :MOD
          raise_error 'Stack Size Less than 2','MOD' if @stack.size() <= 1
          top1 = @stack.pop
          top2 = @stack.pop
          @stack.push top2 % top1
        when :STORE
          raise_error 'Stack Size Less than 2','STORE' if @stack.size() <= 1
          top1 = @stack.pop
          top2 = @stack.pop
          @heap[top2] = top1
        when :RETRIEVE
          raise_error 'Stack is Empty','RETRIEVE' if @stack.size() == 0
          top = @stack.pop
          @stack.push @heap[top]
        when :LABEL
          # NOP
          ;
        when :CALL
          raise_error 'Not Found Label', 'CALL' unless @label[program[p][1]]
          call.push p
          p = @label[program[p][1]]
        when :JUMP
          raise_error 'Not Found Label', 'JUMP' unless @label[program[p][1]]
          p = @label[program[p][1]]
        when :JUMPIFZERO
          raise_error 'Not Found Label', 'JUMPIFZERO' unless @label[program[p][1]]
          raise_error 'Stack is Empty','JUMPIFZERO' if @stack.size() == 0
          if @stack.pop() == 0
            p = @label[program[p][1]]
          end
        when :JUMPIFNEG
          raise_error 'Not Found Label', 'JUMPIFNEG' unless @label[program[p][1]]
          raise_error 'Stack is Empty','JUMPIFNEG' if @stack.size() == 0
          if @stack.pop < 0
            p = @label[program[p][1]]
          end
        when :RET
          raise_error 'Not Called','RET' if call.size() == 0
          p = call.pop()
        when :END
          break
        when :PUTCHAR
          raise_error 'Stack is Empty', 'PUTCHAR' if @stack.size() == 0
          begin
            top = @stack.pop
            STDOUT.print top.chr("UTF-8")
          rescue RangeError => e
            raise_error "Invaild Character: #{top}", 'PUTCHAR'
          end
        when :PUTINT
          raise_error 'Stack is Empty', 'PUTINT' if @stack.size() == 0
          STDOUT.print @stack.pop
        when :GETCHAR
          raise_error 'Stack is Empty', 'GETCHAR' if @stack.size() == 0
          @heap[@stack.pop()] = getchar()
        when :GETINT
          raise_error 'Stack is Empty', 'GETINT' if @stack.size() == 0
          @heap[@stack.pop()] = getint()
        end
        p += 1
      end
    rescue ProgramError => e
      if @options[:raise]
        raise e
      end
    end
  end

  # プログラムを設定する。テスト用。
  def set_program(program)
    @program = program
  end

  # プログラムを解析する
  # [Return]
  #   \[\[\:add],\[\:push,3\]\]のような形式でプログラムが返される
  def get_program()
    ret = []
    commands = [  # コマンドの定義 
      [:PUSH, [0,0,] ,:number],
      [:DUP, [0,2,0,] ,false],
      [:COPY, [0,1,0,] ,:number],
      [:SWAP, [0,2,1,] ,false],
      [:POP, [0,2,2,] ,false],
      [:SLIDE, [0,1,2,] ,:number],
      [:ADD, [1,0,0,0,] ,false],
      [:SUB, [1,0,0,1,] ,false],
      [:MUL, [1,0,0,2,] ,false],
      [:DIV, [1,0,1,0,] ,false],
      [:MOD, [1,0,1,1,] ,false],
      [:STORE, [1,1,0,] ,false],
      [:RETRIEVE, [1,1,1,] ,false],
      [:LABEL, [2,0,0,] ,:label],
      [:CALL, [2,0,1,] ,:label],
      [:JUMP, [2,0,2,] ,:label],
      [:JUMPIFZERO, [2,1,0,] ,:label],
      [:JUMPIFNEG, [2,1,1,] ,:label],
      [:RET, [2,1,2,] ,false],
      [:END, [2,2,2,] ,false],
      [:PUTCHAR, [1,2,0,0,] ,false],
      [:PUTINT, [1,2,0,1,] ,false],
      [:GETCHAR, [1,2,1,0,] ,false],
      [:GETINT, [1,2,1,1,] ,false],
    ]
    p = 0 # ポインタ変数
    haserror = catch(:wrong_program) do # 戻り値がnilならエラー無し
      while @program[p]
        matched = false
        commands.each do |command|
          ok = true
          command[1].size.times do |i|
            if command[1][i] != @program[p + i]
              ok = false
              break
            end
          end
          if ok
            p += command[1].size
            if command[2] == :number
              num, p = get_number(p)
              ret <<= [command[0], num]
            elsif command[2] == :label
              label, p = get_label(p)
              ret <<= [command[0], label]
            else
              ret <<= [command[0]]
            end
            matched = true
            break
          end
        end
        unless matched
          throw :wrong_program, 1
        end
      end
    end

    if haserror && (!@options[:ignore_analyze_error])
      raise AnalyzeError.new('Wrong Program')
    end

    return ret
  end

  # プログラムに含まれるラベルを全て解析し取得する
  # [Return]
  #   labelの集合
  def get_labels(program)
    pc = 0
    program.each do |line|
      if line[0] == :LABEL
        if @label.key?(line[1])
          p @label
          p line[1]
          throw AnalyzeError.new('Multiple Same Label')
        else
          @label[line[1]] = pc
        end
      end
      pc += 1
    end
    return @label
  end

  # プログラムに含まれる数字を取得する
  # [pointer]
  #   数字の解析開始位置
  # [Return]
  #   \[結果の数字, 数字終了時のポインター\]
  def get_number(pointer)
    sign = 1
    if @program[pointer] == 1
      sign = -1
    end
    pointer += 1
    str = ""
    while @program[pointer] && @program[pointer] != 2
      str << @program[pointer].to_s
      pointer += 1
    end
    
    ret = sign * str.to_i(2)
    return [ret, pointer + 1]
  end

  # プログラムに含まれるラベルを取得する
  # [pointer]
  #   ラベルの解析開始位置
  # [Return]
  #   \[結果のラベル(整数), 数字終了時のポインター\]
  def get_label(pointer)
    str = ""
    while @program[pointer] && @program[pointer] != 2
      str << (@program[pointer] + 1).to_s
      pointer += 1
    end
    ret = str.to_i(3)
    return [ret, pointer + 1]
  end
end
