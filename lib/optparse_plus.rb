require "optparse_plus/version"
require 'optparse'
require 'yaml'
require 'ripper'

module OptparsePlus
  attr_reader :opt_plus

  module ClassMethods
    def read_after_program_end(cur_file)
      own_source = File.read(cur_file)
      last_token = Ripper.lex(own_source)[-1]
      return nil unless last_token[1] == :on___end__
      start = last_token[0][0]
      own_source.lines[start..-1].join
    end

    def new_with_yaml(config_yaml_source=nil)
      cur_file = caller[0].split(/:/)[0]
      config_yaml_source ||= read_after_program_end(cur_file)
      opt = OptPlus.create_opt(config_yaml_source)

      if block_given?
        yield opt
      else
        opt
      end
    end
  end

  class OptPlus
    attr_reader :config, :config_source, :callbacks
    attr_writer :opt

    ruby_options_yaml_source = <<YAML
optplus_ruby_encoding:
  short: -Eex[:in]
  long: --encoding=ex[:in]
  description: specify the default external and internal character encodings
optplus_ruby_debug:
  short: -d
  long: --debug
  description: set debugging flags (set $DEBUG to true)
YAML

    RUBY_OPTIONS = YAML.load(ruby_options_yaml_source)
    RUBY_OPTION_TO_LABEL = {
      "E" => :optplus_ruby_encoding,
      "d" => :optplus_ruby_debug,
    }

    def self.create_opt(config_yaml_source)
      opt_plus = OptPlus.new(config_yaml_source)

      if banner = opt_plus.config["banner"]
        opt = ::OptionParser.new(banner)
      else
        opt = ::OptionParser.new
      end

      opt.setup_opt_plus(opt_plus)
      opt
    end

    def initialize(config_yaml_source)
      @config_source = config_yaml_source
      @config = YAML.load(config_yaml_source)
      @ruby_option_callbacks = ruby_option_callbacks
      @callbacks = {}
      @opt = nil
    end

    def opt_on
      @callbacks.keys.each {|label| reflect_callback(label) }
    end

    def reflect_callback(label)
      callback = @callbacks[label]
      args = config_to_args(label)
      @opt.on(*args, callback)
    end

    def config_to_args(label, config=@config)
      options = config[label.to_s]
      %w(short long desc description).map {|type| options[type] }
        .select {|option| not option.nil? }.flatten
    end

    def inherit_ruby_options(*short_option_names)
      short_option_names.each do |opt_name|
        label = RUBY_OPTION_TO_LABEL[opt_name]
        args = config_to_args(label, RUBY_OPTIONS)
        callback = @ruby_option_callbacks[label]
        @opt.on(*args, callback)
      end
    end

    private

    def ruby_set_encoding(given_opt)
      external, internal = given_opt.split(/:/o, 2)
      Encoding.default_external = external if external and not external.empty?
      Encoding.default_internal = internal if internal and not internal.empty?
    end

    def ruby_set_debug
      $DEBUG = true
    end

    def ruby_option_callbacks
      {}.tap do |callbacks|
        callbacks[:optplus_ruby_encoding] = proc {|given_opt| ruby_set_encoding(given_opt) }
        callbacks[:optplus_ruby_debug] = proc {|given_opt| ruby_set_debug }
      end
    end
  end

  def with(option_label, &callback)
    @opt_plus.callbacks[option_label] = callback
  end


  def on_with(option_label, &callback)
    args = @opt_plus.config_to_args(option_label)
    _orig_on(*args, callback)
  end

  def on(*args, &callback)
    if args.length == 1 and args[0].kind_of? Symbol
      on_with(*args, &callback)
    else
      super(*args)
    end
  end

  def parse!
    @opt_plus.opt_on
    super
  end

  def setup_opt_plus(opt_plus)
    @opt_plus = opt_plus
    opt_plus.opt = self
  end

  def inherit_ruby_options(*short_option_names)
    @opt_plus.inherit_ruby_options(*short_option_names)
  end
end

class OptionParser
  alias :_orig_on :on
  private :_orig_on
  prepend OptparsePlus
  extend OptparsePlus::ClassMethods
  private_class_method :read_after_program_end
end
