#!/usr/bin/env ruby

begin
  require 'commandline'
rescue LoadError
  require 'rubygems'
  retry
end

#
# An application demonstrating customizing of canonical options
#
class App < CommandLine::Application

  def initialize
    version           "0.0.1"
    author            "Author Name"
    copyright         "2005, Jim Freeze"
    short_description "A simple app example that takes two arguments."
    long_description  "This app is a simple application example that supports "+
                      "three options and two commandline arguments."

    option :version, :names => %w(--version -v --notice-the-change-from-app5)
    option :debug, :arity => [0,1], :arg_description => "debug_level",
           :opt_description => "Set debug level from 0 to 9."
    option :help

    expected_args   :param_file, :out_file
  end

  def main
    puts "main called"
    puts "@param_file = #{@param_file}"
    puts "@out_file   = #{@out_file}"
  end
end#class App

