#!/usr/bin/env ruby

begin
  require 'commandline'
rescue LoadError
  require 'rubygems'
  retry
end

class App < CommandLine::Application
  def initialize
    options :debug, :version
    option :names => "-test",
           :opt_description => "Set debug level from 0 to 9"

    expected_args :file1, :file2
  end

  def main
    puts "running"
  end
end #class App

