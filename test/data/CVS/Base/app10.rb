#!/usr/bin/env ruby

begin
  require 'commandline'
rescue LoadError
  require 'rubygems'
  retry
end

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
    options :debug, :version
    option :names => "-test",
           :opt_description => "Set debug level from 0 to 9"

    expected_args :command
  end

  def main
    puts "running"
  end

  #####################
  # COMMANDS
  #####################
  # Commands start with a single underscore
  def _help
    # make necessary configurations from app options
    parse
  end

  def _single
    parse
  end

  def _double
  end

  def _arity
  end

end #class App

