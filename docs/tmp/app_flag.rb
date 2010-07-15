
require 'rubygems'
require 'commandline'

class App < CommandLine::Application
  def initialize
    option :flag, :names => %w(--my-flag -m)
    option :help
  end
end


