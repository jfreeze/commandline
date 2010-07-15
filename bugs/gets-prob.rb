require 'rubygems'
require 'commandline'

class App < CommandLine::Application
    def initialize
        version           VERSION
        author            "Esteban Manchado Velázquez"
        copyright         "Copyright (c) 2006, Fotón Sistemas Inteligentes"
        synopsis          "new-project-name [skeleton-name]"
        short_description "Ultimate Command-Line Project Wizard"
        long_description  "Directory-tree, programmable, extensible template system"

        options :debug, :help

        expected_args :something
    end

    def main
        puts "This is what you get: #{@something}"
        puts gets
    end
end

