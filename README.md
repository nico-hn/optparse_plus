# OptparsePlus

OptParsePlus adds some helper methods to OptionParser, and let you define command line options more easily.

In your script, simply require 'optparse_plus' in stead of 'optparse', then the new methods of OptionParser are available for you.

## Installation

Add this line to your application's Gemfile:

    gem 'optparse_plus'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install optparse_plus

## Usage

For example, save the following script as `test_program.rb`:

```ruby
#!/usr/bin/env ruby

require 'optparse_plus'

first_value, second_value = nil, nil

OptionParser.new_with_yaml do |opt|
  opt.inherit_ruby_options("E") # Currently, -E and -d only are available options

  opt.on(:first_option) {|status| first_value = status }
  opt.on(:second_option) {|arg| second_value = arg }
  opt.parse!
end

puts "The value returned from the first option is '#{first_value}'"
puts "The value returned from the second option is '#{second_value}'"

__END__
banner: test_program.rb [OPTION]
first_option:
  short: -f
  long: --first
  description: First option for a test script
second_option:
  short: -s [arg]
  long: --second [=arg]
  description: Second option for a test script
```

And if you execute:

    $ ruby test_program.rb --help

You will see the following message:

```
test_program [OPTION]
    -E, --encoding=ex[:in]           specify the default external and internal character encodings
    -f, --first                      First option for a test script
    -s, --second [=arg]              Second option for a test script
```

Or if you execute:

    $ ruby test_program.rb --first --second=something

You will get the following result:

```
The value returned from the first option is 'true'
The value returned from the second option is 'something'
```

You can also pass YAML data as a string:

```ruby
#!/usr/bin/env ruby

require 'optparse_plus'

first_value, second_value = nil, nil

  config_yaml =<<YAML
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

OptionParser.new_with_yaml(config_yaml) do |opt|
  opt.inherit_ruby_options("E") # Currently, -E and -d only are available options

  opt.on(:first_option) {|status| first_value = status }
  opt.on(:second_option) {|arg| second_value = arg }
  opt.parse!
end

puts "The value returned from the first option is '#{first_value}'"
puts "The value returned from the second option is '#{second_value}'"
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
