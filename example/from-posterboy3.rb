#!/usr/bin/env ruby

require 'rubygems'
require 'pp'
require 'commandline'

opts = []
opts << CommandLine::Option.new(:flag, :posix, :names => %w(-a))
opts << CommandLine::Option.new(:flag, :posix, :names => %w(-b))
opts << CommandLine::Option.new(:flag, :names => %w(--with-c))
pp CommandLine::OptionParser.new(:posix, opts).parse(["--with-c -a"])

