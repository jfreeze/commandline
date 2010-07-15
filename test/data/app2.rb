#!/usr/bin/env ruby

require 'rubygems'
require 'commandline'

#
# A minimum application
#
class App < CommandLine::Application

  def initialize
    expected_args 1
  end

end#class App

