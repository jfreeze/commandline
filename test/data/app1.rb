#!/usr/bin/env ruby

require 'commandline'
include CommandLine


class App < Application

  def initialize
    version           "0.0.1"
    author            "Author Name"
    copyright         "2005, Jim Freeze" # autofill this
    synopsis          "[-dv] [-f output_file] other_stuff"
    long_description  " long "
    short_description " short "

    @option_parser = OptionParser.new {  |o|
      o.add_option :flag,
                   :names           => %w(--version -v), 
                   :opt_description => "Prints version - #{version}"
      o.add_option :names           => %w(--file -f),
                   :arity           => [1,-1],
                   :opt_description => "Define the output filename.",
                   :arg_description => "output_file",
                   :opt_found       => lambda {},
                   :opt_not_found   => lambda {}
      o.add_option :flag,
                   :names           => %w(--debug -d),
                   :opt_description => "Prints backtrace on errors and "+
                                          "debug status to stdout."
    }

    expected_args 1
  end

  def main
  end
end#class App

