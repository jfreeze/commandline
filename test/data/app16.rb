#!/usr/bin/env ruby

require 'rubygems'
require 'commandline'
require 'pp'


class App < CommandLine::Application
  def initialize
    author "First Last"
    short_description "CVS like command sample app"
    synopsis "[app-options] command [cmd-options] [cmd-args]"

    options :debug, :version, :help
    expected_args :command
    
    command :name => "cmd_1_extra",
            :arg_description => "<arg>",
            :cmd_description => "This is the description of cmd_1",
            :synopsis => "cmd_1 <arg>",
            :short_description => "This is the short description of cmd_1" do

      option :flag, :names => %w(--file -f),
             :opt_found => get_args
      expected_args :fred
    end

    command :name => "cmd_2",
            :arg_description => "<arg>",
            :cmd_description => "This is the description of cmd_2",
            :synopsis => "cmd_2 <arg1> <arg2>",
            :short_description => "This is the short description of cmd_1" do

      option :flag, :names => %w(--file -f),
             :opt_found => get_args
      expected_args [2,2]
    end
  
  end
  
  def main
    puts "running main"
    p opt
    p args
  end

  def cmd_1
    puts "Running command 'cmd_1'"
    p opt
    p args
  end
    
  def cmd_2
    puts "Running command 'cmd_2'"
    p opt
    p args
  end
  
end #class App

