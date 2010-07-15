
require 'rubygems'
require 'commandline'

class App < CommandLine::Application

  def initialize
    short_description "fred app"
    options :help, :debug


  end

  def main
    puts "in main"
  end

end
