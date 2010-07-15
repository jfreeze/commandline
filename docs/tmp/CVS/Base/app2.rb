#!/usr/bin/env ruby
require 'rubygems'
require 'commandline'

class App < CommandLine::Application

  def initialize
    synopsis "help me out here!"
    expected_args :file, :fred
  end

  def main
    p "#{name} called with #{@args.size} arguments: #{@args.inspect}"
  end

end#class App
