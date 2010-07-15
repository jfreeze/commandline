#  $Id: application.rb,v 1.4 2005/09/20 19:11:17 jdf Exp $
#  $Source: /Users/jdf/projects/CVSROOT/devel/ruby/commandline/lib/commandline/short_descriptionion.rb,v $
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

#
#  
#
module CommandLine

class Command
  attr_accessor :options, :arg_names, :arg_arity
  
  ATTR_LIST = [:name,              # name of command on commandline. Default method
               :use_method,        # if present, name of method to use for command
               #:arity,            # arg arity is handled with expected_args
               :cmd_description,   # command description for help page
               :arg_description,   # argument description for command
               :synopsis,          # command synopsis
               :short_description, # short description of command for help page
               :long_description   # longer description of command for help page
               ]

  def initialize(attrs)
    @attrs = {}
    @attrs.merge!(attrs)

    @attrs.each { |k,v| raise "Invalid command attribute '#{k}'." unless
      ATTR_LIST.include?(k) }
    
    # Add missing key so check for use_method won't raise exception
    @attrs[:use_method] ||= nil
  end
  
  def method_missing(sym, *args, &block)
    if @attrs.has_key?(sym)
      @attrs[sym]
    else
      raise "Unknown attribute '#{sym}'."
    end
  end
end#class Command

# TODO: The below is not yet supported.
# =User defined option shortcuts
# Methods for use as user defined shortcuts begin with a double underscore "__" 
# Users may define option shortcuts -- hashes containing a default
# definition of an option in a hash format -- by defining methods
# with the name __<opt_name>.
#
# =Private Variables and Methods of Application
# Private variables and methods are preceded with a single underscore, "_".
#
class Application
  DFLT_REPLAY_FILE = ".replay"
  
  class ApplicationError          < StandardError; end
  class OptionError               < ApplicationError; end
  class MissingMainError          < ApplicationError; end
  class InvalidArgumentArityError < ApplicationError; end
  class ArgumentError             < ApplicationError; end
  class UnknownOptionError        < ApplicationError; end

  param_accessor :version, :author, :copyright, :synopsis,
                 :short_description, :long_description,
                 :option_parser

  attr_reader :args, :argv
  
  #
  # TODO: Consolidate these with OptionParser - put in command line
  #
  DEFAULT_CONSOLE_WIDTH = 70
  MIN_CONSOLE_WIDTH     = 10
  DEFAULT_BODY_INDENT   =  4

  def initialize
    @synopsis         = ""
    @arg_arity        = [0,0]
    @options          = []
    @arg_names        = []
    @args             = []
    @replay           = false
    @replay_file      = DFLT_REPLAY_FILE
    @commands         = []
    @current_command  = nil
    @command_hash     = {}
    @command_redirect = {}
    @use_posix        = false
    
    __initialize_text_formatting

    # Call the child usurped initialize
    __child_initialize if 
      self.class.private_instance_methods(false).include?("__child_initialize")

    @option_parser ||= CommandLine::OptionParser.new(
      {:posix => @use_posix, :command_mode => !@commands.empty?}, @options)
  end

  def options(*opts)
    opts.each { |opt| option(*[opt].flatten) }
  end

  def option(*args)
    # options is adjusted automaticaly to reference the options for
    # the application  or the options for the current command
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
    @options << CommandLine::Option.new(*new_list)
  end

  def command(attrs={})
    raise "Cannot determine name for command #{attrs.inspect}." unless
      attrs.has_key?(:name)

    @commands << Command.new(attrs)
    @current_command = @commands.last
    @command_hash[@current_command.name] = @current_command

    begin
      save_options, save_arg_names, save_arg_arity = @options, @arg_names, @arg_arity
      @options = []
      @current_command.options   = @options
      yield if block_given?
    ensure
      @current_command.arg_names = @arg_names
      @current_command.arg_arity = @arg_arity
      @options, @arg_names, @arg_arity = save_options, save_arg_names, save_arg_arity
    end
  end
  
  # Alternative for @option_data["<--opt>"], but with symbols
  def opt
    @option_data
  end
  alias :opts :opt
  
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

  def use_replay(attribs = {})
    @replay = true
    @replay_file = attribs[:replay_file] || @replay_file
  end

  def usage
    if @commands.empty?
      " Usage: #{name} #{synopsis}"
    else
      f = new_text_format
      s = []
      
      s << " Usage: #{name} #{synopsis}"
      cell_width = @commands.collect { |c| c.name.size }.max + @body_indent
      s << _format_manpage_category(:commands, 
        @commands.collect { |c| sprintf("%-#{cell_width}s%s", 
          c.name, c.cmd_description) }, f)

      s.flatten!
      s.compact!
      s.join("\n")
    end
  end

  def new_text_format
    require 'text/format'
    f = Text::Format.new
    f.columns = @columns
    f.first_indent  = @body_indent
    f.body_indent   = @body_indent
    f.tag_paragraph = false
    f
  end
  private :new_text_format
  
  def man
    f = new_text_format
    
    s = []
    s << _format_manpage_category(:name, short_description, f)
    s << _format_manpage_category(:synopsis, synopsis, f)
    s << _format_manpage_category(:description, long_description, f)

    s << option_parser.to_s unless option_parser.nil?

    s << _format_manpage_category(:author, author, f)
    s << _format_manpage_category(:copyright, copyright, f)

    s.flatten!
    s.compact!
    s.join("\n")
  end
  alias :help :man

  def _format_manpage_category(category, text, f)
    # empty categories are not to be displayed.
    return nil if text.nil? || text.empty?

    case category
    when :name
      ["NAME", "", f.format("#{name} - #{text}")]
    when :synopsis
      ["SYNOPSIS", "", f.paragraphs(text)]
    when :description
      ["DESCRIPTION", "", f.paragraphs(text)]
    when :author
      ["AUTHOR  #{text}"]
    when :copyright
      ["COPYRIGHT (c) #{text}"]
    when :commands
      f.body_indent   = 0 # this may be a bug, because it still indents, but does not
                          # put a empty line between the commands
      f.tag_paragraph = false
      [""," Commands:", "", text.collect { |t| " "*(1+@body_indent) + t }.join("\n")]
    else
      raise "DEVELOPER ERROR: Don't know '#{category}' as a category type."
    end
  end
  private :_format_manpage_category

  def name
    File.basename(pathname)
  end

  def pathname
    @@appname
  end

  # TODO: Change this so that a symbol is used and then mapped to 
  # a name like __get_arg so we can avoid collisions with the user.
  def get_arg
    CommandLine::OptionParser::GET_ARGS
  end
  alias :get_args :get_arg

  def append_arg
    CommandLine::OptionParser::GET_ARG_ARRAY
  end

  # should this be arg_required
  # TODO: How are collisions handled with options? Add some tests.
  def required
    CommandLine::OptionParser::OPT_NOT_FOUND_BUT_REQUIRED
  end
  
  def use_posix
    @use_posix = true
  end
  
  def self.run(argv=ARGV)
    # Usurp an existing initialize so ours can be called first.
    # We rename the users initialize to __child_initialize and call
    # it from Applications initialize.
    if self.private_instance_methods(false).include?("initialize")
      $VERBOSE, verbose = nil, $VERBOSE
      self.class_eval {
        alias :__child_initialize :initialize
        remove_method :initialize
      }
      $VERBOSE = verbose
    else
      # look for mispelling of initialize and warn if find one
      result = self.instance_methods.grep(/^i\S*[nt]\S*[nt]\S*z/)
      unless result.empty?
        puts "WARNING: Possible mispelling of 'initialize'? #{result.inspect}"
      end
    end

    obj = self.new
    obj.__parse_command_line(argv)
    obj.main
    
    obj.__do_command unless obj.opt.cmd.nil?

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
      __set_auto_run
    end
  end

  def self.__set_auto_run
    at_exit { @@child_class.run }
  end
  
  def main
    #raise(MissingMainError, "Method #main must be defined in class #{@@child_class}.")
    @@child_class.class_eval %{ def main; end }
    #self.class_eval %{ def main; end }
  end

  def __save_argv
    return unless @replay

    line = 0
    File.open(@replay_file, "w") { |f|
      @argv.each { |arg|
        f.puts "\n" if arg[0] == ?- && line != 0
        f.print " #{arg}"
        line += 1
      }
    }
  end
  
  def __restore_argv
    @argv = File.read(@replay_file).gsub(/\n/, "").split
    raise "Bad @argv" unless @argv.kind_of?(Array)
  end
  
  def __parse_command_line(argv)
    @argv = argv
    if @replay && File.exist?(@replay_file) && !@argv.grep("-r").empty?
      __restore_argv
    elsif @argv.empty? && ( (@arg_arity[0] != 0) || (!@commands.empty?))
      puts usage
      exit(0)
    end

    begin
      @option_data = @option_parser.parse(@argv)

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
    
    __save_argv
  end

  # A better name here would be good.
  # When handling a command type option, @option_data contains information for
  # both the app and the yet to be parsed cmd commandline.
  # The effective argv for the command is stored in #not_parsed
  #  #opts       - application
  #  #argv       - application
  #  #args       - application - always empty in this case
  #  #cmd        - command
  #  #not_parsed - command
  def __do_command
    @current_command = @command_hash[opt.cmd]
    
    # Restore instance_methods
    @arg_names = @current_command.arg_names
    @arg_arity = @current_command.arg_arity
    @options   = @current_command.options
    
    cmd_argv = opt.not_parsed

#TODO: command is not validated here yet!.
    @option_parser = CommandLine::OptionParser.new(
                      {:posix => @use_posix, :command_mode => false},
                      @command_hash[@option_data.cmd].options)

    @option_data = @option_parser.parse(cmd_argv)
    @args        = @option_data.args

    @arg_names.each_with_index { |name, idx|
      instance_variable_set("@#{name}", @option_data.args[idx])
    }

    send(@current_command.use_method || @current_command.name)
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

  def __initialize_text_formatting
    #
    # Formatting defaults
    #
    console_width = (c=ENV["COLUMNS"]).nil? ? DEFAULT_CONSOLE_WIDTH : c.to_i

    @columns =
      if console_width < MIN_CONSOLE_WIDTH
        MIN_CONSOLE_WIDTH
      else
        [console_width - DEFAULT_BODY_INDENT, MIN_CONSOLE_WIDTH].max
      end

    @body_indent   = DEFAULT_BODY_INDENT
    @tag_paragraph = false
    @order         = :index  # | :alpha
  end

  def __validate_args(od_args)
    size = od_args.size
    min, max = @arg_arity
    max = 1.0/0.0 if -1 == max
    if size < min
      if opt.cmd
        unless @commands.find { |cmd| cmd.name == opt.cmd}
          raise(ArgumentError,
            "Unknown command '#{opt.cmd}'\n#{usage}")
        else
          # "Should never get here. Should be caught by std usage from 0 arguments on CL"
          p opt.args
          p opt.cmd
          p opt.not_parsed
          raise(ArgumentError, "Missing command. #{size} < #{min}")
        end
      else
        raise(ArgumentError,
          "Missing expected arguments. Found #{size} but expected #{min}. "+
          "#{od_args.inspect}\n"+
          "#{usage}") 
      end
    end
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
                               puts "#{name} - Version: #{version}"
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

BasicApplication = Class.new(Application)
class BasicApplication  # No AutoRun
  def self.inherited(child_class)
    @@appname = caller[0][/.*:/][0..-2]
    @@child_class = child_class
  end
end

=begin
# Need to change the above around to
Application = Class.new(BasicApplication)
class BasicApplication  # No AutoRun
  def self.inherited(child_class)
    super
    if @@appname == $PROGRAM_NAME
      __set_auto_run
    end
  end
end

=end
end#module CommandLine
