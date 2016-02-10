require 'test_helper'
require 'colorize'

class DictionaryTest < Minitest::Test
  # This line includes all default Spout Dictionary tests
  include Spout::Tests

  # This line provides access to @variables, @forms, and @domains
  # iterators that can be used to write custom tests
  include Spout::Helpers::Iterators

  VALID_UNITS = [
    '', 'beats per minute', 'centimeters', 'cigarettes', 'days',
    'days from index date', 'days per week', 'degrees',
    'desaturations per hour', 'events', 'events per hour', 'feet', 'hours',
    'inches', 'kilograms', 'medications', 'micro-units per milliliter',
    'micrograms per milliliter', 'milligrams per deciliter',
    'millimeters of mercury', 'milliseconds', 'minutes', 'minutes per day',
    'missing items', 'nanograms per milliliter', 'naps', 'ovaries', 'percent',
    'periods', 'picograms per milliliter', 'pounds', 'readings', 'seconds',
    'units per liter', 'years', 'obstructive apnea events',
    'kilograms per meters squared']

  @variables.select{|v| ['numeric','integer'].include?(v.type)}.each do |variable|
    define_method('test_units: '+variable.path) do
      message = "\"#{variable.units}\"".colorize( :red ) + " invalid units.\n" +
                '             Valid types: ' +
                VALID_UNITS.sort.collect{|u| u.inspect.colorize( :white )}.join(', ')
      assert VALID_UNITS.include?(variable.units), message
    end
  end

  @variables.each do |variable|
    define_method('test_dnames: '+variable.path) do
      message = 'Display name should not be blank'
      assert variable.display_name.to_s.strip != '', message
    end
  end

  @variables.each do |variable|
    define_method('test_check_calc_description: '+variable.path) do
      message = 'Calculations should not be in descriptions'
      assert variable.description.to_s.scan(variable.calculation.to_s.strip).count == 0 || variable.calculation.to_s.strip == '', message
    end
  end

  @variables.each do |variable|
    define_method('test_check_calculation_display_name: '+variable.path) do
      message = 'Calculations should not be in display names'
      assert variable.display_name.to_s.scan(variable.calculation.to_s.strip).count == 0 || variable.calculation.to_s.strip == '', message
    end
  end
end
