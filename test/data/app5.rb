#!/usr/bin/env ruby

begin
  require 'commandline'
rescue
  require 'rubygems'
  retry
end

class App < CommandLine::Application

  def initialize
    version           "0.0.1"
    author            "Author Name"
    copyright         "2005, Jim Freeze"
    long_description  "app5 is a simple application example that supports "+
                      "three options and two commandline arguments."
    short_description "A simple app example that takes two arguments."
    #other_description??

    option :version
    option :debug
    option :help

    expected_args   :param_file, :out_file
  end

  def main
    puts "main called"
    puts "@param_file = #{@param_file}"
    puts "@out_file   = #{@out_file}"
  end
end#class App

