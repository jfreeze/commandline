  #!/usr/bin/env ruby

  require 'rubygems'
  require 'commandline'

  class App < CommandLine::Application
    def initialize
      author    "Author Name"
      copyright "Author Name, 2005"
      synopsis "[-dh] [--in-file <in_file>] file"
      short_description "Example application with one arg"
      long_description "put your long description here!"
      options :help, :debug
      option  :names => "--in-file", :opt_found => get_args,
              :opt_description => "Input file for sample app.",
              :arg_description => "input_file"
      expected_args :file
    end

    def main
      puts "args: #{args}"
      puts "--in-file: #{opt "--in-file"}"
    end
  end#class App
