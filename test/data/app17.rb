#!/usr/bin/env ruby

require 'rubygems'
require 'commandline'
require 'pp'

# 
# Command Test - Example of what help should look like:
# % app10.rb help
# or
# % app10.rb --help
#
# NAME
#
#   app10.rb - A commandline example application
#
# SYNOPSIS
#
#   app10.rb [-dhv] <cmd> [OPTIONS]
#
# COMMANDS
#
#     <cmd>           <cmd_summary>
#     help            Displays help page
#     single          takes single argument
#     double          takes two arguments
#     arity           takes 0 to unlimited args
#
# OPTIONS
#
#     --version,-v
#         Displays application version.
#
#     --debug,-d debug_level
#         Set debug level from 0 to 9.
#
#     --help,-h
#         Displays help page.
#
# AUTHOR:  Author Name
# COPYRIGHT (c) 2005, Author Name
#
# =================================== Individual command
# % app10.rb help help
#
# Usage: app10.rb [-dvh] help [command]     
#                                     Displays general help page or 
#                                     help for a command
#
# Footer?
# =================================== Individual command
# % app10.rb help single
#
# Usage: app10.rb [-dvh] single [OPTIONS] ARGUMENT     
#                                     Command that takes a single argument
#
# OPTIONS
#
#     --fred,-f       sample option
#
# Footer?
# =================================== Individual command
# % app10.rb help double
#
# Usage: app10.rb [-dvh] double [OPTIONS] ARGUMENT1 ARGUMENT2
#
# DESCRIPTION
#
#      Command that takes a single argument
#
# OPTIONS
#
#     --fred,-f       sample option
#
#     --other-options,-o       
#                     example of other sample option
#
# Footer?
# =================================== Individual command
# % app10.rb help arityy
#
# Usage: app10.rb [-dvh] arity [OPTIONS] [ARGUMENT...]
#                                     Command that takes a single argument
#
# OPTIONS
#
#     --fred,-f       sample option
#
#     --other-options,-o       
#                     example of other sample option
#
# Footer?
#
#

class App < CommandLine::Application
  def initialize
    author "First Last"
    short_description "CVS like command sample app"
    synopsis "[app-options] command [cmd-options] [cmd-args]"

    option :names => "--source",
           :arg_description => "URL",
           :opt_description => "Use URL as the remote source for gems",
           :opt_found => get_arg
    option :names => %w(--http-proxy -p),
           :arg_description => "URL",
           :opt_description => "Use HTTP proxy for remote operations",
           :opt_found => get_arg
    option :flag,
           :names => "--no-http-proxy",
           :opt_description => "Do not use HTTP proxy for remote operations"
    option :help,
           :arg_description => "Get help on 'build' command"
    option :names => "--config-file",
           :arg_description => "FILE",
           :opt_description => "Use this config file instead of default",
           :opt_found => get_args
    option :flag,
           :names => "--backtrace",
           :opt_description => "Show stack backtrace on errors"
    option :debug,
           :opt_description => "Turn on Ruby debugging"

#    expected_args :command

    setup_command_build
    setup_command_install
    setup_command_search
  end

  def local_remote_both_options
    option :flag,
           :names => %w(--local -l),
           :opt_description => "Restrict operations to the LOCAL domain (default)"
    option :flag,
           :names => %w(--remote -r),
           :opt_description => "Restrict operations to the REMOTE domain"
    option :flag,
           :names => %w(--both -b),
           :opt_description => "Allow LOCAL and REMOTE operations"
  end

  def setup_command_search
    command :name => "search", 
            :cmd_description => "Display all gems whose name contains STRING",
            :arg_description => "STRING",
            :synopsis => "search [STRING] [options]" do
      option :flag,
             :names => %w(--details -d),
             :opt_description => "Display detailed information of gem(s)"

      local_remote_both_options
    end
  end
  
  def setup_command_install
    command :name => "install",
            :arg_description => "GEMNAME",
            :cmd_description => "name of gem to install",
            :synopsis => "[-dlrb] SEARCH_STRING",
            :short_description => "Display all gems whose name contains SEARCH_STRING" do

      option :names => %w(--version -v),
             :arg_description => "VERSION",
             :opt_description => "Specify version of gem to install",
             :opt_found => get_args
      local_remote_both_options
      option :names => %w(--install-dir -i),
             :arg_description => "DIR",
             :opt_found => get_args
      option :flag,
             :names => %w(--rdoc -d),
             :opt_description => "Generate RDoc documentation for the gem on install"
      option :flag,
             :names => %w(--force -f),
             :opt_description => "Force gem to install, bypassing dependency checks"
      option :flag,
             :names => %w(--test -t),
             :opt_description => "Run unit tests prior to installation"
      option :flag,
             :names => "--ignore-dependencies",
             :opt_description => "Do not install any required dependent gems"
      option :flag,
             :names => "--include-dependencies",
             :opt_description => "Unconditionally install the required dependent gems"
    end
  end
  
  def setup_command_build
    command :name              => "build",
            :arg_description   => "GEMSPEC_FILE",
            :cmd_description   => "name of gemspec file used to build the gem",
            :synopsis          => "[options] GEMSPEC_FILE",
            :short_description => "Build a gem from a gemspec" do
      expected_args :arg1, :arg2
    end
  end

  def main
    puts "running"
    # we could give the power of calling the command to the user
    # method(@command).call
  end

  def build
    puts "Running command 'build'"
    puts "@arg1: #{@arg1}"
    puts "@arg2: #{@arg2}"
#    p opt
  end
  
  def install
    puts "Running command 'search'"
    p opt
  end
  
  def search
    puts "Running command 'search'"
    p opt
  end
  
  #####################
  # COMMANDS
  #####################
  # Built-in Commands start with a single underscore
  def _help
    # make necessary configurations from app options
  end

  def _single
  end

  def _double
  end

  def _arity
  end

end #class App

