#!/usr/bin/env ruby
require 'rubygems'
require 'commandline'

# A minimum application
class App < CommandLine::Application
  def initialize
    option :debug, :arity => [1,1],
           :opt_description => "Set debug level from 0 to 9"
    option :version

    expected_args :file1, :file2
  end
end #class App

