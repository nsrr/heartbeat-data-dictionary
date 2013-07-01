require 'test_helper'

class DictionaryTest < Test::Unit::TestCase
  include Spout::Tests

  # You may add additional tests here
  # def test_truth
  #   assert true
  # end

  def test_variable_uniqueness
    files = Dir.glob("variables/**/*.json").collect{|file| file.split('/').last }
    assert_equal [], files.select{ |f| files.count(f) > 1 }.uniq
  end

end
