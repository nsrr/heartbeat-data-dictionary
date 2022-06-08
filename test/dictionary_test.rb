# frozen_string_literal: true

# require "test_helper"

require "spout/tests"

# Launches default Spout tests and custom tests for specific to this dictionary.
class DictionaryTest < Minitest::Test
  # This line includes all default Spout Dictionary tests.
  include Spout::Tests::JsonValidation
  include Spout::Tests::DomainExistenceValidation
  include Spout::Tests::DomainFormat
  include Spout::Tests::DomainNameFormat
  include Spout::Tests::DomainNameUniqueness
  include Spout::Tests::DomainSpecified
  include Spout::Tests::FormExistenceValidation
  include Spout::Tests::FormNameFormat
  include Spout::Tests::FormNameMatch
  include Spout::Tests::FormNameUniqueness
  # include Spout::Tests::VariableDisplayNameLength
  include Spout::Tests::VariableNameFormat
  include Spout::Tests::VariableNameMatch
  include Spout::Tests::VariableNameUniqueness
  include Spout::Tests::VariableTypeValidation

  # This line provides access to @variables, @forms, and @domains iterators
  # iterators that can be used to write custom tests.
  include Spout::Helpers::Iterators

  # Example 1: Create custom tests to show that `integer` and `numeric`
  # variables have a valid unit type.
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
    'kilograms per meter squared', 'central apneas', 'obstructive apneas',
    'kilograms per square meter','cmH2O',nil ]

  @variables.select { |v| %w(numeric integer).include?(v.type) }.each do |variable|
    define_method("test_units: #{variable.path}") do
      message = "\"#{variable.units}\"".red + " invalid units.\n" +
                "             Valid types: " +
                VALID_UNITS.sort_by(&:to_s).collect { |u| u.inspect.white }.join(", ")
      assert VALID_UNITS.include?(variable.units), message
    end
  end

  # Example 2: Create custom tests to show that variables have 2 or more labels.
  # @variables.select { |v| %w(numeric integer).include?(v.type) }.each do |variable|
  #   define_method("test_at_least_two_labels: #{variable.path}") do
  #     assert_operator 2, :<=, variable.labels.size
  #   end
  # end

  # Example 3: Create regular Ruby tests
  # You may add additional tests here
  # def test_truth
  #   assert true
  # end
end
