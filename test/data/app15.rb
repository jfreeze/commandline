#!/usr/bin/env ruby

require 'commandline'
require 'pp'

# Test BasicApplication and man page with multiple paragraphs
class App < CommandLine::BasicApplication

  def initialize
    version "0.0.15"
    options :version, :debug, :help
    synopsis "[-v] [--name name]"
    author "Author Name"
    copyright "2005"
    short_description "This is a short description"
    long_description ["This is a long description with 3 paragraphs.",
                      "The second paragraph that is long. "*4,
                      "And the third paragraph. "*2]
  end

  def main
    print "ARGV =  "; pp @argv
    print "args:   "; pp args
#    print "@option_data: "; pp @option_data
#    print "--name: "; puts opt.name
    print "--name: "; puts opt['--name']
    
  end
end #class App

App.run