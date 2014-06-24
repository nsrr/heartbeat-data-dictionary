require 'test_helper'
require 'colorize'

class DictionaryTest < Minitest::Test
  # This line includes all default Spout Dictionary tests
  include Spout::Tests

  # This line provides access to @variables, @forms, and @domains
  # iterators that can be used to write custom tests
  include Spout::Helpers::Iterators

  VALID_UNITS = ["", "beats per minute", "centimeters", "cigarettes", "days per week", "desaturations per hour", "events", "events per hour", "feet", "hours", "inches", "kilograms", "millimeters of mercury", "milliseconds", "minutes", "naps", "ovaries", "percent", "periods", "pounds", "readings", "seconds", "years"]

  @variables.select{|v| ['numeric','integer'].include?(v.type)}.each do |variable|
    define_method("test_units: "+variable.path) do
      message = "\"#{variable.units}\"".colorize( :red ) + " invalid units.\n" +
                "             Valid types: " +
                VALID_UNITS.sort.collect{|u| u.inspect.colorize( :white )}.join(', ')
      assert VALID_UNITS.include?(variable.units), message
    end
  end

  @variables.each do |variable|
    define_method("test_dnames: "+variable.path) do
      message = "Display name should not be blank"
      assert variable.display_name.to_s.strip != "", message
    end
  end

  # @variables.each do |variable|
  #   define_method("test_check_calc_description: "+variable.path) do
  #     message = "Calculations should not be in descriptions"
  #     assert variable.description.to_s.scan(variable.calculation.to_s.strip).count == 0, message
  #   end
  # end

end
