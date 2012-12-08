require 'test/unit'
require './' + File.dirname(__FILE__) + '/../../core/VM.rb'

# VMのテストをするクラス
class VMTest < Test::Unit::TestCase
  def setup()
    @obj = VM.new
  end
  
  def test_get_program()
    testcases = [
      [[2,2,2], [[:END]]],
      [[1], []],
      [[0,0,1,1], [[:PUSH,-1]]],
      [[2,0,0,1,2], [[:LABEL,2]]],
      [[2,2,2,2,2,2], [[:END],[:END]]],
    ]
    testcases.each do |testcase, excepted|
      @obj.__send__('set_program',testcase)
      ret = @obj.__send__('get_program')
      assert_equal(ret, excepted)
    end
  end

  def test_get_labels()
    testcase = [2,2,2,2,0,0,1,2]
    @obj.__send__('set_program',testcase)
    ret = @obj.__send__('get_program')
    ret = @obj.__send__('get_labels', ret)
    assert_equal(ret, {2 => 1})
  end

  def test_get_number()
    testcases = [
      [[1,1,0,1,0,2],-10],
      [[0,1,0,1,0,2],10],
      [[0,1,0,0,0,0,0,2],32],
    ]
    testcases.each do |testcase, excepted|
      @obj.__send__('set_program', testcase)
      ret = @obj.__send__('get_number', 0)
      assert_equal(ret[0], excepted)
      assert_equal(ret[1], testcase.size)
    end
  end

  def test_get_label()
    testcases = [
      [[1,2],2],
      [[0,1,2],5],
      [[0,2],1],
    ]
    testcases.each do |testcase, excepted|
      @obj = VM.new
      @obj.__send__('set_program', testcase)
      ret = @obj.__send__('get_label', 0)
      assert_equal(ret[0], excepted)
      assert_equal(ret[1], testcase.size)
    end
  end

  def test_run_analyzed()
    @obj = VM.new(:ignore_analyzed_error => true, :show_error => true)
    @obj.run_analyzed [[:PUSH,12354],[:DUP],[:PUTINT],[:PUTCHAR]] # エラーの有無の確認

  end
end
