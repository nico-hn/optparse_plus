require 'spec_helper'
require File.join(__dir__, 'test_scripts/main')

describe OptparsePlus do
  it 'should have a version number' do
    expect(OptparsePlus::VERSION).to_not be_nil
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

  context("when options are described in a multi-lines string") do
    it 'accepts --second option with an argument' do
      parser = OptparsePlusTest.new
      set_argv("--first --second=something")
      parser.parse_with_string_as_source
      expect(parser.second_option_value).to eq("something")
    end

    it 'accepts --first option' do
      parser = OptparsePlusTest.new
      set_argv("--first --second=something")
      parser.parse_with_string_as_source
      expect(parser.first_option_given?).to be_truthy
    end

    it '--second option may not be given' do
      parser = OptparsePlusTest.new
      set_argv("--first")
      parser.parse_with_string_as_source
      expect(parser.second_option_value).to be_nil
    end

    it '--first option may not be given' do
      parser = OptparsePlusTest.new
      set_argv("--second=something")
      parser.parse_with_string_as_source
      expect(parser.first_option_given?).to be_falsy
    end
  end

  context("when options are registered using OptionParser#on_with") do
    it 'accepts --second option with an argument' do
      parser = OptparsePlusTest.new
      set_argv("--first --second=something")
      parser.parse_using_on_with
      expect(parser.second_option_value).to eq("something")
    end

    it 'accepts --first option' do
      parser = OptparsePlusTest.new
      set_argv("--first --second=something")
      parser.parse_using_on_with
      expect(parser.first_option_given?).to be_truthy
    end

    it '--second option may not be given' do
      parser = OptparsePlusTest.new
      set_argv("--first")
      parser.parse_using_on_with
      expect(parser.second_option_value).to be_nil
    end

    it '--first option may not be given' do
      parser = OptparsePlusTest.new
      set_argv("--second=something")
      parser.parse_using_on_with
      expect(parser.first_option_given?).to be_falsy
    end
  end

  context("when options are registered using OptionParser#on") do
    it 'accepts normal definitions' do
      parser = OptparsePlusTest.new
      set_argv("--first --second=something")
      parser.parse_normal_definitions_using_on
      expect(parser.first_option_given?).to be_truthy
      expect(parser.second_option_value).to eq("something")
    end

    it 'accepts --second option with an argument' do
      parser = OptparsePlusTest.new
      set_argv("--first --second=something")
      parser.parse_using_on
      expect(parser.second_option_value).to eq("something")
    end

    it 'accepts --first option' do
      parser = OptparsePlusTest.new
      set_argv("--first --second=something")
      parser.parse_using_on
      expect(parser.first_option_given?).to be_truthy
    end

    it '--second option may not be given' do
      parser = OptparsePlusTest.new
      set_argv("--first")
      parser.parse_using_on
      expect(parser.second_option_value).to be_nil
    end

    it '--first option may not be given' do
      parser = OptparsePlusTest.new
      set_argv("--second=something")
      parser.parse_using_on
      expect(parser.first_option_given?).to be_falsy
    end
  end

  describe 'creation of an instance of OptionParser' do
    before do
      @config_yaml_with_banner = <<YAML
banner: #{File.basename($0)} [OPTION]
first_option:
  long: --first
  short: -f
  description: First option for a test script
second_option:
  short: -s [arg]
  description: Second option for a test script
YAML

      @config_yaml_without_banner = <<YAML
first_option:
  short: -f
  long: --first
  description: First option for a test script
second_option:
  short: -s [arg]
  long: --second [=arg]
  description: Second option for a test script
YAML
    end

    it 'expects to assign OptionParser#banner if the value is in the configuration' do
      opt = OptionParser::OptPlus.create_opt(@config_yaml_with_banner)
      expect(opt.banner).to eq('rspec [OPTION]')
    end

    it 'expects to assign a default value to OptionParser#banner unless the value is specified in the configuration' do
      opt = OptionParser::OptPlus.create_opt(@config_yaml_without_banner)
      expect(opt.banner).to eq('Usage: rspec [options]')
    end

    it 'expects to assign an instance of OptPlus to OptionParser#opt_plus' do
      opt = OptionParser::OptPlus.create_opt(@config_yaml_without_banner)
      expect(opt.opt_plus).to be_instance_of(OptionParser::OptPlus)
    end
  end

  describe OptionParser::OptPlus do
    before do
      @config_yaml_with_banner = <<YAML
banner: #{File.basename($0)} [OPTION]
first_option:
  long: --first
  short: -f
  description: First option for a test script
second_option:
  short: -s [arg]
  description: Second option for a test script
YAML

      @config_yaml_without_banner = <<YAML
first_option:
  short: -f
  long: --first
  description: First option for a test script
second_option:
  short: -s [arg]
  long: --second [=arg]
  description: Second option for a test script
YAML
    end

    describe '.new_with_yaml' do
      it 'should not call File.read class method directly' do
#        expect(File).to receive(:read) do
          OptionParser.new_with_yaml(@config_yaml_with_banner)
#        end
        raise "An appropriate test should be added."
      end
    end

    describe '#config_to_args' do
      it 'can convert config in yaml to args of OptionParser#on' do
        opt_plus = OptionParser::OptPlus.new(@config_yaml_without_banner)
        args = opt_plus.config_to_args(:first_option)
        expect(args).to eq(["-f", "--first", "First option for a test script"])
      end

      it 'expects to sort the order of arguments (short long desc)' do
        opt_plus = OptionParser::OptPlus.new(@config_yaml_with_banner)
        args = opt_plus.config_to_args(:first_option)
        expect(args).to eq(["-f", "--first", "First option for a test script"])
      end

      it 'may ignore missing arguments' do
        opt_plus = OptionParser::OptPlus.new(@config_yaml_with_banner)
        args = opt_plus.config_to_args(:second_option)
        expect(args).to eq(["-s [arg]", "Second option for a test script"])
      end
    end

    describe '#inherit_ruby_options' do
      before do
        @external_encoding = Encoding.default_external
        @internal_encoding = Encoding.default_internal
      end

      after do
        Encoding.default_external = @external_encoding
        Encoding.default_internal = @internal_encoding
      end

      it 'can add -E option' do
        Encoding.default_external = 'UTF-8'
        expect(Encoding.default_external).to eq(Encoding::UTF_8)

        set_argv("-EWindows-31J")
        OptionParser.new_with_yaml(@config_yaml_with_banner) do |opt|
          opt.inherit_ruby_options("E")
          opt.parse!
        end

        expect(Encoding.default_external).to eq(Encoding::Windows_31J)
      end

      it '-E option accepts an internal only arguement such as -E:Windows-31J' do
        Encoding.default_internal = 'UTF-8'
        expect(Encoding.default_internal).to eq(Encoding::UTF_8)

        set_argv("-E:Windows-31J")
        OptionParser.new_with_yaml(@config_yaml_with_banner) do |opt|
          opt.inherit_ruby_options("E")
          opt.parse!
        end

        expect(Encoding.default_internal).to eq(Encoding::Windows_31J)
      end

      it 'expect to print help message' do
        expected_help_message = <<HELP
rspec [OPTION]
    -E, --encoding=ex[:in]           specify the default external and internal character encodings
HELP

        allow(STDOUT).to receive(:puts).with(expected_help_message)

        set_argv("--help")
        OptionParser.new_with_yaml(@config_yaml_with_banner) do |opt|
          opt.inherit_ruby_options("E")
          opt.parse!
        end
      end
    end
  end
end
