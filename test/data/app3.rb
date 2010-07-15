#!/usr/bin/env ruby

require 'rubygems'
require 'commandline'

#
# A minimum application
#
class App < CommandLine::Application

  def initialize
    synopsis   "[-v] [-f output_file] other_stuff"

    option :flag,
           :names           => %w(--version -v), 
           :opt_description => "Prints version - #{version}"
    option :names           => %w(--file -f),
           :arity           => [1,-1],
           :opt_description => "Define the output filename.",
           :arg_description => "output_file",
           :opt_found       => get_arg
    expected_args 1
  end

  def main
  end
end#class App

