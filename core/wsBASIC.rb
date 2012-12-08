require_relative 'Scanner.rb'
require_relative 'Parser.rb'
require_relative 'PreProcessor.rb'
require_relative 'Generator.rb'
require_relative 'VM.rb'

class WsBASIC
  # スクリプトを実行する
  def run(filename)
    lib = PreProcessor.pre_process(File.dirname(__FILE__) + '/../lib/stdlib.bas')
    ret = lib.concat(PreProcessor.pre_process(filename))
    codes = Parser.new.try_parse(ret)
    codes = codes.compile
    ary = Generator.new.generate(codes.join("\n"))
    #print(ary.map{|v|
#      if v == 0
#        " "
#      elsif v == 1
#        "\t"
#      elsif v == 2
#        "\n"
 #     end}.join(''))
    VM.new.run(ary)
  end
  
  # WhiteSpaceコードの生成`
  def converToWhitespace(filename, output)
    lib = PreProcessor.pre_process(File.dirname(__FILE__) + '/../lib/stdlib.bas')
    ret = lib.concat(PreProcessor.pre_process(filename))
    codes = Parser.new.try_parse(ret)
    codes = codes.compile
    ary = Generator.new.generate(codes.join("\n"))
    ws = (ary.map{|v|
      if v == 0
        " "
      elsif v == 1
       "\t"
      elsif v == 2
        "\n"
      end
    }.join(''))
    File.open(output, "w") do |file|
      file.print(ws)
    end
  end
end
if ARGV.size == 0
  STDERR.puts "Run: wsbas FileName"
  STDERR.puts "Generate Whitespace Code: wsbas -w FileName Output"
end

if ARGV[0] != "-w"
  WsBASIC.new.run ARGV[0]
else
  WsBASIC.new.converToWhitespace ARGV[1], ARGV[2]
end
