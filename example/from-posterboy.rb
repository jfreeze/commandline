#!/usr/bin/env ruby

require 'rubygems'
require 'commandline'

class App < CommandLine::Application
  def initialize
      use_posix
      options :help
      option :posix, :flag, :names => "-d"
      option :posix, :flag, :names => "-v",
        :opt_found => lambda { puts "Version 1.0" }
   end

  def main
      puts "call your library here"
  end
end#class App
