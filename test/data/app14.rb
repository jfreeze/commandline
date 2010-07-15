#!/usr/bin/env ruby

require 'commandline'
require 'pp'

class App < CommandLine::Application

  def initialize
    version "3.2.1"
    options :debug, :version
    synopsis "[-v] [--name name]"
    option :names => "--name",
           :opt_description => "Name",
           :arg_description => "name",
           :opt_found => get_args
    
#    expected_args :none
  end

  def main
    print "ARGV =  "; pp @argv
    print "args:   "; pp args
#    print "@option_data: "; pp @option_data
    print "--name: "; puts opt.name
  end
end #class App

