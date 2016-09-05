#!/usr/bin/env ruby

require(File.join(__dir__, "cli"))

class OptparsePlusTest
  def first_option_given?
    @first_option_given
  end
end
