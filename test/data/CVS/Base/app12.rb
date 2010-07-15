#!/usr/bin/env ruby

#
# Replay Test
#

begin
  require 'commandline'
rescue LoadError
  require 'rubygems'
  retry
end

class App < CommandLine::Application
  def initialize
    use_replay
    options :debug, :version
    option :names => "-test",
           :opt_description => "Set debug level from 0 to 9"

    expected_args :file1, :file2
  end

  def main
    puts "running with args: #{@file1}, #{@file2}"
  end
end #class App

