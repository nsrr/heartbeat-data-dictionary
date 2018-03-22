# frozen_string_literal: true

require 'test_helper'

# Launches default Spout tests and custom tests for specific to this dictionary.
class DictionaryTest < Minitest::Test
  # This line includes all default Spout Dictionary tests
  include Spout::Tests

  # This line provides access to @variables, @forms, and @domains iterators
  # that can be used to write custom tests.
  include Spout::Helpers::Iterators

  # Example 1: Create custom tests to show that `integer` and `numeric`
  # variables have a valid unit type.
  VALID_UNITS = [
    '', 'beats per minute (bpm)', 'centimeters (cm)', 'cigarettes', 'days',
    'days from index date', 'days per week', 'degrees',
    'desaturations per hour', 'events', 'events per hour', 'feet (ft)', 'hours (hr)',
    'inches (in)', 'kilograms (kg)', 'medications', 'micro-units per milliliter (mcU/mL)',
    'micrograms per milliliter (ug/mL)', 'milligrams per deciliter (mg/dL)',
    'millimeters of mercury (mmHg)', 'milliseconds (ms)', 'minutes (min)', 'minutes per day',
    'missing items', 'nanograms per milliliter (ng/mL)', 'naps', 'ovaries', 'percent (%)',
    'periods', 'picograms per milliliter (pg/mL)', 'pounds (lb)', 'readings', 'seconds (s)',
    'units per liter', 'years (yr)', 'obstructive apnea events',
    'kilograms per meter squared (kg/m2)', 'central apneas', 'obstructive apneas',
    nil ]

  @variables.select { |v| %w(numeric integer).include?(v.type) }.each do |variable|
    define_method("test_units: #{variable.path}") do
      message = "\"#{variable.units}\"".colorize(:red) + " invalid units.\n" +
                "             Valid types: " +
                VALID_UNITS.sort_by(&:to_s).collect { |u| u.inspect.colorize(:white) }.join(', ')
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
