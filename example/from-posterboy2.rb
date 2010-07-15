#!/usr/bin/env ruby

require 'rubygems'
require 'commandline'

class App < CommandLine::Application
  def initialize
      options :help, :debug
      option :flag, :names => %w(--version -v),
        :opt_found => lambda { puts "Version 1.0" }
   end

  def main
      puts "call your library here"
  end
end#class App
