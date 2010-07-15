#!/usr/bin/env ruby
require 'rubygems'
require 'commandline'

class App < CommandLine::Application

  def initialize
    synopsis "[-dh] file"
    expected_args :file
  end

  def main
    puts "#{name} called with #{args.size} arguments: #{args.inspect}"
    puts "@file = #{@file}"
  end

end#class App
