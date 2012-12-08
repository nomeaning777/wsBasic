# == プリプロセッサ
# プリプロセッサは以下のことを実行する
# - コメントの除去('以下を消去)
# - _Space_\_が最後にある行の継続 
# - 行番号等の取得
# - セミコロンによる分割
class PreProcessor
  # プリプロセス中に発生したエラーを表す
  class PreProcessError < StandardError
  end
  # プリプロセッサを実行する
  # [Return]
  #   \[ファイル名, 行番号, 行の内容\]のような形式の配列の配列が返される
  def self.pre_process(filename)
    ret = []
    file = File.read(filename)
    lines = file.split("\n")
    lines.size().times do |line_no|
      line = lines[line_no]
      l = ""
      mode = :normal
      try_redo = false
      line.size.times do |i|
        if mode == :normal
          if line[i] == '"'
            mode = :string
            l <<= '"'
          elsif line[i] == "\t"
            l <<= ' '
          elsif line[i] == "'"
            break
          elsif line[i] == ':'
            ret <<= [filename, line_no + 1, l.strip]
            lines[line_no] = line.slice(i+1, line.size())
            try_redo = true
            break
          else
            l <<= line[i]
          end
        elsif mode == :string
          if line[i] == '"'
            l <<= '"'
            mode = :normal
          elsif line[i] == '\\'
            l <<= '\\'
            l <<= line[i+1]
            i += 1
          else
            l <<= line[i]
          end
        end
      end
      if try_redo
        redo
      end
      if mode == :string
        raise PreProcessError.new("Invalid Syntax (String or Char Enclosure) on Line #{line_no + 1} ,File #{filename}")
      end
      ret <<= [filename, line_no + 1, l.strip]
    end

    tmp = ret
    ret = []
    s = []
    str = ""
    i = 0
    while i < tmp.size()
      j = i
      str = tmp[j][2]
      while j < tmp.size() - 1 && / _$/ =~ str
        str = str.slice(0, str.size()-2)
        j += 1  
        str += " " + tmp[j][2]
      end
      ret <<= [tmp[i][0], tmp[i][1], str]
      i = j + 1
    end
    return ret
  end
end
