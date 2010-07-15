#!/usr/bin/env ruby 

require 'rubygems'
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")

tc = Dir["tc_*rb"]

tc = tc.grep(Regexp.new(ARGV[0])) unless ARGV.empty?

tc.each { |lib|
  fork { 
    require lib 
  }
}

