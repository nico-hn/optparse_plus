require 'spec_helper'
require File.join(__dir__, 'test_scripts/main')

describe OptparsePlus do
  it 'should have a version number' do
    OptparsePlus::VERSION.should_not be_nil
  end

  context("when options are described under __END__") do
    it 'accepts --second option with an argument' do
      parser = OptparsePlusTest.new
      set_argv("--first --second=something")
      parser.parse_with_after_end
      expect(parser.second_option_value).to eq("something")
    end

    it 'accepts --first option' do
      parser = OptparsePlusTest.new
      set_argv("--first --second=something")
      parser.parse_with_after_end
      expect(parser.first_option_given?).to be_truthy
    end

    it '--second option may not be given' do
      parser = OptparsePlusTest.new
      set_argv("--first")
      parser.parse_with_after_end
      expect(parser.second_option_value).to be_nil
    end

    it '--first option may not be given' do
      parser = OptparsePlusTest.new
      set_argv("--second=something")
      parser.parse_with_after_end
      expect(parser.first_option_given?).to be_falsy
    end
  end
end
