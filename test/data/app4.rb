#!/usr/bin/env ruby

require 'rubygems'
require 'commandline'


class App < CommandLine::Application

  def initialize
    version           "0.0.1"
    author            "Author Name"
    copyright         "2005, Jim Freeze" # autofill this
    synopsis          "[-dv] [-f output_file] other_stuff"
    long_description  " long "
    short_description " short "
    #other_description??

    option :names           => %w(--file -f),
           :arity           => [1,-1],
           :opt_description => "Define the output filename.",
           :arg_description => "output_file",
           :opt_found       => lambda {},
           :opt_not_found   => lambda {}
    option :version
    option :debug,
           :opt_description => "Prints backtrace on errors and "+
           "debug status to stdout."
    option :help

    expected_args   :file
  end

#  def main
#  end
end#class App

