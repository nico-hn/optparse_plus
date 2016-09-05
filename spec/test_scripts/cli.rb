#!/usr/bin/env ruby

require 'optparse_plus'

class OptparsePlusTest
  attr_accessor :first_option_given, :second_option_value

  OPTION_YAML_SOURCE = <<YAML
banner: #{File.basename($0)} [OPTION]
first_option:
  short: -f
  long: --first
  description: First option for a test script
second_option:
  short: -s [arg]
  long: --second [=arg]
  description: Second option for a test script
YAML

  def parse_with_after_end
    OptionParser.new_with_yaml do |opt|
      opt.with(:first_option) {|status| @first_option_given = status }
      opt.with(:second_option) {|arg| @second_option_value = arg }
      opt.parse!
    end
  end

  def parse_with_string_as_source
    OptionParser.new_with_yaml(OPTION_YAML_SOURCE) do |opt|
      opt.with(:first_option) {|status| @first_option_given = status }
      opt.with(:second_option) {|arg| @second_option_value = arg }
      opt.parse!
    end
  end

  def parse_using_on_with
    OptionParser.new_with_yaml(OPTION_YAML_SOURCE) do |opt|
      opt.on_with(:first_option) {|status| @first_option_given = status }
      opt.on_with(:second_option) {|arg| @second_option_value = arg }
      opt.parse!
    end
  end

  def parse_using_on
    OptionParser.new_with_yaml(OPTION_YAML_SOURCE) do |opt|
      opt.on('-f', '--first',
             'First option for a test script') {|status| @first_option_given = status }
#      opt.on(:first_option) {|status| @first_option_given = status }

#      opt.on('-s [arg]', '--second [=arg]',
#             'Second option for a test script') {|arg| @second_option_value = arg }
      opt.on(:second_option) {|arg| @second_option_value = arg }
      opt.parse!
    end
  end
end

__END__
banner: test_program [OPTION]
first_option:
  short: -f
  long: --first
  description: First option for a test script
second_option:
  short: -s [arg]
  long: --second [=arg]
  description: Second option for a test script
