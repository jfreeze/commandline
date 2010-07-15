#!/usr/bin/ruby

begin
print "getting "; puts gets
        puts "*"*80

#require 'rubygems'
require 'commandline'

print "getting "; puts gets

class App < CommandLine::BasicApplication
    def initialize
        author            "Esteban Manchado Veláuez"
        synopsis          "file"

        expected_args :something
#print "getting "; puts gets
    end

    def main
        puts "This is what you get: #{@something}"
        print "enter something: "
        ans = Kernel.gets
        p ans
        rescue => err
        puts err
        puts err.backtrace
    end
end

#App.run
rescue => err
puts err
puts err.backtrace
end
