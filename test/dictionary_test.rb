require 'test_helper'

class DictionaryTest < Test::Unit::TestCase
  include Spout::Tests

  VALID_UNITS = ['readings','%','milliseconds','','hours','events per hour','events','mmHG','minutes','seconds','bpm','cm','years old','days per week','naps','ovaries','periods','cigarettes','kg','ft','in','lb'] #Example ['mmHG','bpm','readings','minutes','%','hours','MET']

  def assert_units(units, msg = nil)
    full_message = build_message(msg, "? invalid units. Valid types: #{VALID_UNITS.join(', ')}", units)
    assert_block(full_message) do
      VALID_UNITS.include?(units)
    end
  end

  def assert_domain_present(domain_name, msg = nil)
    full_message = build_message(msg, "Variables of type choices need to specify a domain")
    assert_block(full_message) do
      domain_name != nil
    end
  end

  Dir.glob("variables/**/*.json").each do |file|
    if ['numeric','integer'].include?(json_value(file, :type))
      define_method("test_units: "+file) do
        assert_units json_value(file, :units)
      end
    end
  end

  Dir.glob("variables/**/*.json").each do |file|
    if json_value(file, :type) == "choices"
      define_method("test_domain_present:"+file) do
        assert_domain_present json_value(file, :domain)
      end
    end
  end
end
