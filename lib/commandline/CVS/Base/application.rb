#  $Id: application.rb,v 1.4 2005/09/20 19:11:17 jdf Exp $
#  $Source: /Users/jdf/projects/CVSROOT/devel/ruby/commandline/lib/commandline/application.rb,v $
#
#  Author: Jim Freeze
#  Copyright (c) 2005
#
# =DESCRIPTION
# Framework for commandline applications
#
# =Revision History
#  Jim.Freeze 06/02/2005 Birthday - kinda
#  Jim.Freeze 09/19/2005 fixed @arg_arity bug and copyright print bug

require 'commandline/utils'
require 'commandline/optionparser'

module CommandLine
class Application
  class ApplicationError          < StandardError; end
  class OptionError               < ApplicationError; end
  class MissingMainError          < ApplicationError; end
  class InvalidArgumentArityError < ApplicationError; end
  class ArgumentError             < ApplicationError; end

  param_accessor :version, :author, :copyright, :synopsis,
                 :short_description, :long_description,
                 :option_parser

  #
  # TODO: Consolidate these with OptionParser - put in command line
  #
  DEFAULT_CONSOLE_WIDTH = 70
  MIN_CONSOLE_WIDTH     = 10
  DEFAULT_BODY_INDENT   =  4

  def initialize
    @synopsis       = ""
    @arg_arity     = [0,0]
    @options       = []
    @arg_names     = []
    @args          = []
    @argv        ||= ARGV
    @replay        = false

    __init_format

    __child_initialize if 
      self.class.private_instance_methods(false).include?("__child_initialize")

    @option_parser ||= CommandLine::OptionParser.new(@options)
  end

  def options(*opts)
    opts.each { |opt| option(*[opt].flatten) }
  end

  def option(*args)
    @options ||= []
    new_list = []
    args.each { |arg|
      new_list << 
      case arg
        when :help    then __help
        when :debug   then __debug
        when :verbose then __verbose
        when :version then __version
        else arg
      end
    }
    #p new_list
    @options << CommandLine::Option.new(*new_list)
  end

  #
  # expected_args tells the application how many arguments (not belonging
  # any option) are expected to be seen on the command line
  # The names of the args are used for describing the synopsis (or usage).
  # If there is an indeterminant amount of arguments, they are not
  # named, but returned in an array.
  # expected_args takes either a list of argument names
  #
  # =Usage
  #   expected_args :sym1
  #   expected_args :sym1, :sym2, ...
  #   expected_args n    #=> arg_arity => [n,n]
  #   expected_args arity
  #
  # =Examples
  #
  # Many forms are valid. Some examples follow:
  #   expected_args 0                #=> @args = []; same as not calling expected_args
  #   synopsis: Usage: app

  #   expected_args 1                #=> @args is array
  #   synopsis: Usage: app arg

  #   expected_args 2                #=> @args is array
  #   synopsis: Usage: app arg1 arg2

  #   expected_args 10               #=> @args is array
  #   synopsis: Usage: app arg1 ... arg10

  #   expected_args :file            #=> @file = <arg>
  #   synopsis: Usage: app file

  #   expected_args :file1, :file2   #=> @file1 = <arg1>, @file2 = <arg2>
  #   synopsis: Usage: app file1 file2

  #   expected_args [0,1]            #=> @args is array
  #   synopsis: Usage: app [arg1 [arg2]]

  #   expected_args [2,3]            #=> @args is array
  #   synopsis: Usage: app arg1 arg2 [arg3]

  #   expected_args [0,-1]           #=> @args is array
  #   synopsis: Usage: app [arg1 [arg...]]
  #

  #   expected_args :cmd
  #   Now, what to do if command line has more args than expected
  #   app --app-option cmd --cmd-option arg-for-cmd
  #
  def expected_args(*exp_args)
    @arg_names = []
    case exp_args.size
    when 0 then @arg_arity = [0,0]
    when 1
      case exp_args[0]
      when Fixnum 
        v = exp_args[0]
        @arg_arity = [v,v]
      when Symbol
        @arg_names = exp_args
        @arg_arity = [1,1]
      when Array
        v = exp_args[0]
        __validate_arg_arity(v)
        @arg_arity = v
      else 
        raise(InvalidArgumentArityError, 
          "Args must be a Fixnum or Array: #{exp_args[0].inspect}.")
      end
    else
      @arg_names = exp_args
      size = exp_args.size
      @arg_arity = [size, size]
    end
  end

  def use_replay
    @replay = true
  end

  def usage
    " Usage: #{name} #{synopsis}"
  end

  def man
    require 'text/format'
    f = Text::Format.new
    f = Text::Format.new
    f.columns = @columns
    f.first_indent  = 4
    f.body_indent   = @body_indent
    f.tag_paragraph = false

    s = []
    s << ["NAME\n"]

    nm = "#{short_description}".empty? ? name : "#{name} - #{short_description}"
    s << f.format(nm)

    sn = "#{synopsis}".empty? ? "" : "#{name} #{synopsis}"
    unless sn.empty?
      s << "SYNOPSIS\n"
      s << f.format(sn)
    end

    dc = "#{long_description}"
    unless dc.empty?
      s << "DESCRIPTION\n"
      s << f.format(dc)
    end

    op = option_parser.to_s
    unless op.empty?
      s << option_parser.to_s
    end

    ar = "#{author}"
    unless ar.empty?
      s << "AUTHOR:  #{ar}"
    end


    ct = "COPYRIGHT (c) #{copyright}"
    unless "#{copyright}".empty?
      s << ct
    end

    s.join("\n")
  end
  alias :help :man

  def name
    File.basename(pathname)
  end

  def pathname
    @@appname
  end

  def get_arg
    CommandLine::OptionParser::GET_ARGS
  end
  alias :get_args :get_arg

  def append_arg
    CommandLine::OptionParser::GET_ARG_ARRAY
  end

  def required
    CommandLine::OptionParser::OPT_NOT_FOUND_BUT_REQUIRED
  end
  
  def self.run(argv=ARGV)
    if self.private_instance_methods(false).include?("initialize")
      $VERBOSE, verbose = nil, $VERBOSE
      self.class_eval {
        alias :__child_initialize :initialize
        remove_method :initialize
      }
      $VERBOSE = verbose
    end
    obj = self.new
    obj.__parse_command_line(argv)
    obj.main

    #alias :user_init :initialize
    #@@child_class.new.main if ($0 == @@appname)
    obj
    rescue => err
      puts "ERROR: #{err}"
      exit(-1)
  end

  def self.inherited(child_class)
    @@appname = caller[0][/.*:/][0..-2]
    @@child_class = child_class
    if @@appname == $0
      at_exit { @@child_class.run }
    end
  end

  def main
    #raise(MissingMainError, "Method #main must be defined in class #{@@child_class}.")
    @@child_class.class_eval %{ def main; end }
    #self.class_eval %{ def main; end }
  end

  def __parse_command_line(argv)
    if argv.empty? && 0 != @arg_arity[0]
      puts usage
      exit(0)
    end

    begin
      @option_data = @option_parser.parse(argv)
      @args = @option_data.args
    rescue => err
      puts err
      puts
      puts usage
      exit(-1)
    end

    __validate_args(@option_data.args)
    @arg_names.each_with_index { |name, idx|
      instance_variable_set("@#{name}", @option_data.args[idx])
    }
  end

  def __validate_arg_arity(arity)
    min, max = *arity
    raise(InvalidArgumentArityError, "Minimum argument arity '#{min}' must be "+
      "greater than or equal to 0.") unless min >= 0
    raise(InvalidArgumentArityError, "Maximum argument arity '#{max}' must be "+
      "greater than or equal to -1.") if max < -1
    raise(InvalidArgumentArityError, "Maximum argument arity '#{max}' must be "+
      "greater than minimum arg_arity '#{min}'.") if max < min && max != -1
  end

  def __init_format
    #
    # Formatting defaults
    #
    console_width = ENV["COLUMNS"]
    @columns = 
      if console_width.nil?
        DEFAULT_CONSOLE_WIDTH
      elsif console_width < MIN_CONSOLE_WIDTH
        console_width
      else
        console_width - DEFAULT_BODY_INDENT
      end
    @body_indent   = DEFAULT_BODY_INDENT
    @tag_paragraph = false
    @order         = :index  # | :alpha
  end

  def __validate_args(od_args)
    size = od_args.size
    min, max = @arg_arity
    max = 1.0/0.0 if -1 == max
    raise(ArgumentError,
      "Missing expected arguments. Found #{size} but expected #{min}.\n"+
      "#{usage}") if size < min
    raise(ArgumentError, "Too many arguments. Found #{size} but "+
      "expected #{max}.\n#{usage}") if size > max
  end

  def __help
     {
       :names           => %w(--help -h),
       :arity           => [0,0],
       :opt_description => "Displays help page.",
       :arg_description => "",
       :opt_found       => lambda { puts man; exit },
       :opt_not_found   => false
     }
  end

  def __verbose
     {
       :names           => %w(--verbose -v),
       :arity           => [0,0],
       :opt_description => "Sets verbosity level. Subsequent "+
                           "flags increase verbosity level",
       :arg_description => "",
       :opt_found       => lambda { @verbose ||= -1; @verbose += 1 },
       :opt_not_found   => nil
     }
  end

  def __version
     {
       :names           => %w(--version -V),
       :arity           => [0,0],
       :opt_description => "Displays application version.",
       :arg_description => "",
       :opt_found       => lambda { 
                             begin 
                               version 
                             rescue 
                               puts "No version specified" 
                             end; 
                             exit 
                           },
       :opt_not_found   => nil
     }
  end

  def __debug
     {
       :names           => %w(--debug -d),
       :arity           => [0,0],
       :opt_description => "Sets debug to true.",
       :arg_description => "",
       :opt_found       => lambda { $DEBUG = true }
     }
  end
end#class Application
end#module CommandLine

