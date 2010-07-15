#!/usr/bin/env ruby

$LOAD_PATH.unshift "../lib"
require 'commandline'

class App < CommandLine::Application

  def initialize
    expected_args :file   # will set instance variable @file to command line argument.
  end

  def main
    puts "#{name} called with #{@args.size} arguments: #{@args.inspect}"
    puts "@file = #{@file}"
  end

end#class App
