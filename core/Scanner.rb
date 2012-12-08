# -*- coding:utf-8 -*-

# スキャナー
module Scanner
  # 予約語一覧
  RESERVED = {'SUB' => :SUB,
              'FUNCTION' => :FUNCTION,
              'END' => :END,
              '__VM' => :VM_CALL, 
              '__VM_PUSH' => :VM_PUSH,
              'MOD' => :MOD,
              'AND' => :AND,
              'ANDALSO' => :ANDALSO,
              'TRUE' => :TRUE,
              'FALSE' => :FALSE,
              'NOT' => :NOT,
              'OR' => :OR,
              'ORELSE' => :ORELSE,
              'XOR' => :OR,
              'DIM' => :DIM, 
              'EXIT' => :EXIT,
              'RETURN' => :RETURN,
              'CONST' => :CONST,
              'IF' => :IF,
              'THEN' => :THEN,
              'ELSE' => :ELSE
             }
  
  # スキャンする
  def scan(codes)
    @queue = [] # 字句解析結果を入れるもの
    codes.each do |filename,line_no,line|
      line.strip!
      until line.empty? do
        case line
        when /^\s+/
          ;
        when /^[a-zA-Z_]\w*/
          matched = $&
          if RESERVED.key?(matched.upcase)
            t = RESERVED[matched.upcase]
            @queue.push [filename, line_no, [t, t] ]
          else
            @queue.push [filename, line_no, [:IDENT, $&.intern] ]
          end
        when /^\d+/
          @queue.push [filename, line_no, [:NUMBER, $&.to_i]]
        when /^"(?:[^"\\]+|\\.)*"(c|C)/
          t = $&
          t = t[0...(t.size()-1)]
          @queue.push [filename, line_no, [:CHAR, eval(t)]]
        when /^"(?:[^"\\]+|\\.)*"/
          @queue.push [filename, line_no, [:STRING, eval($&)]]
        when /^(\=\=|<=|>=|<>)/
          @queue.push [filename, line_no, [$&, $&]]
        when /^./
          @queue.push [filename, line_no, [$&, $&]]
        end
        line = $'
      end
      @queue.push [filename,line_no, [:EOL, nil]]
    end
    @queue.push ["",-1,[:EOF,nil]]
    
    # デバッグ用にスキャン結果を表示する
    # @queue.each do |a,b,c|
    #  STDERR.puts c.inspect
    # end
  end
  
  # next_token(racc用)
  def next_token()
    shift = @queue.shift
    if shift
      @line_no = shift[1]
      @filename = shift[0]
      return shift[2]
    end
    return nil
  end
end
