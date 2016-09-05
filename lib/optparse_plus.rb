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

    def config_to_args(label)
      options = @config[label.to_s]
      %w(short long desc).map {|type| options[type] }
        .select {|option| not option.nil? }.flatten
    end
  end

  def with(option_label, &callback)
    @opt_plus.callbacks[option_label] = callback
  end

  def parse!
    @opt_plus.opt_on
    super
  end

  def setup_opt_plus(opt_plus)
    @opt_plus = opt_plus
    opt_plus.opt = self
  end
end

class OptionParser
  prepend OptparsePlus
  extend OptparsePlus::ClassMethods
  private_class_method :read_after_program_end
end
