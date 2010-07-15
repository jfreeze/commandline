#!/usr/bin/env ruby
  require 'commandline'
  require 'rubygems'

  class App < CommandLine::Application
    def initialize
      use_replay
      option :help, :debug
      expected_args :input, :output
    end

    def main
      p @arg_names
      puts "#{name} called with #{@args.size} arguments: #{@args.inspect}"
      puts "input:  #{@input}"
      puts "output: #{@output}"
    end

  end#class App
