#!/usr/bin/env ruby

#
# Replay Test
#

require 'commandline'

class App < CommandLine::Application

  def initialize
    version "0.0.1"
    use_replay
    options :debug, :version
    synopsis "[-dv] [-test level] file1 file2"
    option :names => "-test",
           :opt_found => get_args,
           :opt_description => "Set debug level from 0 to 9"

    expected_args :file1, :file2
  end

  def main
    puts "ARGV = #{@argv.inspect}"
    puts "running with args: #{@file1}, #{@file2}"
  end
end #class App

