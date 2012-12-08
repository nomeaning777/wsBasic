class Parser

prechigh
# 算術演算子
  left '^'
  nonassoc FACTORIAL
  nonassoc UPLUS UMINUS
  left '*' '/' '%'
  left MOD
  left '+' '-'
# 比較演算子
  left '==' '<>' '<' '>' '<=' '>='
# 論理演算子
  left NOT
  left AND ANDALSO
  left OR ORELSE
  left XOR
# 代入演算子
  right '=' '+=' '-=' '*=' '%=' '/='
preclow

expect 3
# IDENT +/- 3
# (callとみてほしい)
# IDENT (AAA)
# funcallとみてほしいがどちらでも動く
# この3つ

start program

rule
  program : toplevel EOF # プログラム全体
            {
              result = ProgramNode.new(@filename, 0, val[0])
            }

  toplevel: {
              result = []
            }
          | toplevel toplevel_statement
            {
              result.push val[1]
            }
          | toplevel EOL
  
  # トップレベルから呼び出される命令
  toplevel_statement: 
          dim_statement EOL |
          function
                    
  dim_statement : DIM declaration_list
                {
                  result = DimStatementNode.new(@filename, @line_no, val[1])
                }
  declaration_list: variable_declaration
                    {
                      result = [val[0]]
                    }
                  | declaration_list ',' variable_declaration
                    {
                      result.push val[2]
                    }

  variable_declaration: IDENT
                        {
                          result = VariableDeclarationNode.new(@filename, @line_no, val[0], NumberNode.new(@filename, @line_no, 0))
                        }
                      | IDENT '=' expression
                        {
                          result = VariableDeclarationNode.new(@filename, @line_no, val[0], val[2])
                        }
                      | CONST IDENT '=' expression
                        {
                          result = ConstantDeclarationNode.new(@filename, @line_no, val[1], val[3])
                        }

  function: SUB IDENT '(' function_argv ')' EOL block END SUB EOL
            {
              result = FunctionNode.new(@filename, @line_no, val[1], val[3], val[6], :subroutine)
            }
          | FUNCTION IDENT '(' function_argv ')' EOL block END FUNCTION EOL
            {
              result = FunctionNode.new(@filename, @line_no, val[1], val[3], val[6], :function)
            }
  function_argv : 
                  {
                    result = []
                  }
                | ident_list

  ident_list: IDENT
              {
                result = [val[0]]
              }
            | ident_list ',' IDENT
              {
                result.push val[2]
              }

  block : {
            result = []
          }
        | block statement EOL
          {
            result.push val[1]
          }
        | block EOL
  
  statement : dim_statement
            | return_statement
            | exit_statement
            | expression_statement
            | call_statement
            | vm_statement
            | vm_push_statement
            | if_statement

  if_statement: IF expression THEN EOL block END IF 
                {
                  result = IFStatementNode.new(@filename, @line_no ,val[1], val[4], [])
                }
              | IF expression THEN EOL block ELSE EOL block END IF
                {
                  result = IFStatementNode.new(@filename, @line_no ,val[1], val[4], val[7])
                }
                
  return_statement: RETURN
                  | RETURN expression
                  {
                    result = ReturnNode.new(@filename, @line_no, val[1])
                  }
  exit_statement: EXIT SUB
                | EXIT FUNCTION
  
  expression_statement: expression
                      {
                        result = ExpressionStatementNode.new(@filename, @line_no, val[0])
                      }
  
  vm_statement: VM_CALL STRING
                {
                  result = VMCallNode.new(@filename, @line_no, val[1])
                }
              | VM_CALL '(' STRING ')'
                {
                  result = VMCallNode.new(@filename, @line_no, val[2])
                }
 
  vm_push_statement : VM_PUSH expression
                      {
                        result = VMPushNode.new(@filename, @line_no, val[1])
                      }
  
  call_statement: IDENT expression_list =CALL
                  {  
                    result = ExpressionStatementNode.new(@filename, @line_no, FunCallNode.new(@filename, @line_no, val[0], val[1]))
                  }
  expression: primary
            |expression '+' expression
              {
                result = OperatorNode.new(@filename, @line_no, val[0], val[2], ['ADD'], &:+)
              }
            | expression '-' expression
              {
                result = OperatorNode.new(@filename, @line_no, val[0], val[2], ['SUB'], &:-)
              }
            | expression '*' expression
              {
                result = OperatorNode.new(@filename, @line_no, val[0], val[2], ['MUL'], &:*)
              }
            | expression '%' expression
              {
                result = OperatorNode.new(@filename, @line_no, val[0], val[2], ['MOD']) { |a, b| a % b }
              }
            | expression MOD expression
              {
                result = OperatorNode.new(@filename, @line_no, val[0], val[2], ['MOD']) { |a, b| a % b }
              }
            | expression '/' expression
              {
                result = OperatorNode.new(@filename, @line_no, val[0], val[2], ['DIV']) { |a, b| a / b }
              }
            | expression '<=' expression
              {
                op_vm = []
                op_vm += ['SUB']
                op_vm += ['DUP']
                op_vm += ['JUMPIFZERO LABEL_1']
                op_vm += ['DUP']
                op_vm += ['JUMPIFNEG LABEL_1']
                op_vm += ['POP']
                op_vm += ['PUSH 0']
                op_vm += ['JUMP LABEL_2']
                op_vm += ['LABEL LABEL_1']
                op_vm += ['POP']
                op_vm += ['PUSH -1']
                op_vm += ['LABEL LABEL_2']
                result = OperatorNode.new(@filename, @line_no, val[0], val[2], op_vm) { |a, b| (a <= b) ? -1 : 0 }
              }
            | '+' primary =UPLUS
              {
                result = val[1]
              }
            | '-' primary =UMINUS
              {
                result = OperatorNode.new(@filename, @line_no, NumberNode.new(@filename, @line_no, 0), val[1], ['SUB'], &:-)
              }
            | primary '!' =FACTORIAL
            
            | expression '=' expression
              {
                result = SubstitutionNode.new(@filename, @line_no, val[0], val[2])
              }
  primary : '(' expression ')'
              {
                result = val[1]
              }
          | NUMBER # 数値
            {
              result = NumberNode.new(@filename, @line_no, val[0])
            }
          | CHAR # 文字
            {
              result = NumberNode.new(@filename, @line_no, val[0].ord)
            }
          | IDENT # 変数
            {
              result = VariableNode.new(@filename, @line_no, val[0])
            }
          | TRUE # 論理値
            {
              result = NumberNode.new(@filename, @line_no, -1)
            }
          | FALSE # 論理値
            {
              result = NumberNode.new(@filename, @line_no, 0)
            }
          | function_call

  function_call: IDENT '(' argv ')' 
                {
                  result = FunCallNode.new(@filename, @line_no, val[0], val[2])
                }
  argv: 
        {
          result = []
        }
      | expression_list

  expression_list : expression
                    {
                      result = [val[0]]
                    }
                  | expression_list ',' expression
                    {
                      result.push val[2]
                    }
end

---- header
require_relative 'Scanner.rb'
dir = File.dirname(__FILE__)
Dir.glob( dir + '/node/*.rb' ) do |f|
  require_relative f # node以下のファイル全てをRequireする
end

---- inner
  include Scanner
  
  def try_parse(codes)
    scan codes
    return do_parse
  end
  
  def on_error(t, val, vstack)
    raise Racc::ParseError, "#{@filename}:#{@line_no}: syntax error on #{val.inspect}"
  end
