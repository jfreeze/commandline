  #!/usr/bin/env ruby

  require 'rubygems'
  require 'commandline'

  class App < CommandLine::Application
    def initialize
      options :help, :debug
      option  :names => "--file", :opt_found => get_args
    end

    def main
      puts "--file: #{opt :file}"
      at_exit { puts "in main" }
    end
  end#class App
