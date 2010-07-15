#!/usr/bin/env ruby
require 'rubygems'
require 'commandline'

class App < CommandLine::Application

  def initialize
    options :help, :debug
  end

  def main
    puts "running"
  end

end#class App
