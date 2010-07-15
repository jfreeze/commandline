#!/usr/bin/env ruby

$LOAD_PATH.unshift "../lib"
require 'commandline'

class App < CommandLine::Application
  def main
    puts "call your library here"
  end
end#class App
