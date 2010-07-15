  #!/usr/bin/env ruby

  require 'rubygems'
  require 'commandline'

  class App < CommandLine::Application
    def initialize
      option :debug, :posix => true
      option :help, :posix => true

      p @options
    end

    def main
      puts "call your library here"
    end
  end#class App

