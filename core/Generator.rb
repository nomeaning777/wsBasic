# 生成されたVMコードからVMで実行出来る形式に変換する
class Generator
  # 初期化
  def initialize
    @command = [
      ["PUSH", "SS", "d"],
      ["DUP","SLS",""],
      ["COPY","STS","d"],
      ["SWAP","SLT",""],
      ["POP","SLL",""],
      ["SLIDE","STL","d"],
    
      ["ADD","TSSS",""],
      ["SUB","TSST",""],
      ["MUL","TSSL",""],
      ["DIV","TSTS",""],
      ["MOD","TSTT",""],
    
      ["STORE", "TTS", ""],
      ["RETRIEVE", "TTT", ""],
    
      ["LABEL", "LSS", "l"],
      ["CALL", "LST", "l"],
      ["JUMP", "LSL", "l"],
      ["JUMPIFZERO", "LTS", "l"],
      ["JUMPIFNEG", "LTT", "l"],
      ["RET", "LTL", ""],
      ["END", "LLL", ""],
    
      ["PUTCHAR", "TLSS", ""],
      ["PUTINT", "TLST", ""],
      ["GETCHAR", "TLTS", ""],
      ["GETINT", "TLTT", ""],
    ]
    
    @labels = Hash.new 
  end
  # コードを変換する
  # [Return]
  #   配列形式でVMのコードが返される
  def generate(code)
    program = ""
    line = 0
    code.split("\n").each do |command|
      command.strip!
      line += 1
      next if /^#.*/ =~ command
      cmd,param = "", ""
      if /^(.+?)\s+(.+?)$/ =~ command
        cmd = $1
        param = $2
      elsif /^(.+)$/ =~ command
        cmd = $1
      end
      next if cmd == ""
      match = false
      @command.each do |command|
        if cmd.upcase == command[0]
          program << command[1]
          if command[2] != "" && param == ""
            show_error line, "Require Parameter"
          end
          if command[2] == "d"
            program << get_number(param)
          elsif command[2] == "l"
            program << get_label(param)
          end
          match = true
        end
      end
      unless match
        show_error line, "No Such Command #{cmd}"
      end
    end
    
    program = program.split(//).map{|v|
      if v == 'S'
        0
      elsif v == 'T'
        1
      elsif v == 'L'
        2
      end
    }
       
    return program
  end

private
  # 数値をVMで扱える形式に変更する
  def get_number(number)
    if number.to_s[0] == "'"
      number=number[1].bytes.to_a[0].to_i
    else
      number=number.to_i
    end
    ret = ""
    if number >= 0
      ret = "S"
    else
      ret = "T"
      number = -number
    end
    ret += number.to_s(2).gsub("1","T").gsub("0","S")
    return ret + "L"
  end
  
  # 同じラベルは同じ数値になり、かつ異なるラベルは異なる数値になるようなハッシュを返す
  def get_label(label)
    unless @labels.key?(label)
      tar = @labels.size + 1
      @labels[label] = tar
      end
    return get_number(@labels[label])
  end
  
  # エラーを管理する
  def show_error(line, mes)
    STDERR.puts "Generator Error: #{mes}"
    throw StandardError.new(mes)
  end
  
end
