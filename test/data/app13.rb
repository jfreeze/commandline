#!/usr/bin/env ruby

require 'commandline'
require 'pp'

class App < CommandLine::Application

  def initialize
    version "1.2.3"
    options :debug, :version
    synopsis "[-dv] [--name name]"
    option :names => "--name",
           :opt_description => "Name",
           :arg_description => "name"
  end

  def main
    print "ARGV =  "; pp @argv
    print "args:   "; pp args
    print "--name: "; puts opt.name
  end
end #class App

