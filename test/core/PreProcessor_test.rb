require 'test/unit'
require './' + File.dirname(__FILE__) + '/../../core/PreProcessor.rb'

# プリプロセッサのテスト
class PreProcessorTest < Test::Unit::TestCase
  def setup()
    @obj = PreProcessor.new
  end

  def test_pre_process()
    p PreProcessor.pre_process(File.dirname(__FILE__) + '/PreProcessor_testcase.cbas')      
  end
end
