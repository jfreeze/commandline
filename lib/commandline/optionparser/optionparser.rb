#  $Id: optionparser.rb,v 1.1.1.1 2005/09/08 15:51:38 jdf Exp $
#  $Source: /Users/jdf/projects/CVSROOT/devel/ruby/commandline/lib/commandline/optionparser/optionparser.rb,v $
#
#  Author: Jim Freeze
#  Copyright (c) 2005 Jim Freeze
#
# =DESCRIPTION
# A very flexible commandline parser
#
# =Revision History
#  Jim.Freeze 04/01/2005 Birthday
#
# :include: README
#

module CommandLine

class OptionParser
  attr_reader :posix, :command_mode, :unknown_options_action,
              :options

  attr_accessor :columns, :body_indent, :tag_paragraph

  DEFAULT_CONSOLE_WIDTH = 70
  MIN_CONSOLE_WIDTH     = 10
  DEFAULT_BODY_INDENT   =  4

  #
  # These helper lambdas are here because OptionParser is the object
  # that calls them and hence knows the parameter order.
  #

  OPT_NOT_FOUND_BUT_REQUIRED = lambda { |opt|  
    raise(MissingRequiredOptionError, 
    "Missing required parameter '#{opt.names[0]}'.") 
  }

  GET_ARG_ARRAY = lambda { |opt, user_opt, _args| _args }

  GET_ARGS = lambda { |opt, user_opt, _args| 
    return true if _args.empty?
    return _args[0] if 1 == _args.size
    _args
  }

  # 
  # Option Errors. Note the oxymoron below for MissingRequiredOptionError.
  # The user can make an option required by adding the OPT_NOT_FOUND_BUT_REQUIRED
  # lambda for the #opt_not_found action.
  #
  class OptionParserError                  < StandardError; end
  class DuplicateOptionNameError           < OptionParserError; end
  class MissingRequiredOptionError         < OptionParserError; end 
  class MissingRequiredOptionArgumentError < OptionParserError; end 
  class UnknownOptionError                 < OptionParserError; end
  class UnknownPropertyError               < OptionParserError; end
  class PosixMismatchError                 < OptionParserError; end

  def initialize(*opts_and_props)
    @posix = false
    @unknown_options_action = :raise
    @unknown_options         = []
    @opt_lookup_by_any_name  = {}
    #@command_options         = nil
    @command_mode            = false

    #
    # Formatting defaults
    #
    # TODO: try getting dims from stty -a
    console_width = ENV["COLUMNS"].to_i
    @columns = 
      if console_width == 0
        DEFAULT_CONSOLE_WIDTH
      elsif console_width < MIN_CONSOLE_WIDTH
        console_width
      else
        console_width - DEFAULT_BODY_INDENT
      end
    @body_indent   = DEFAULT_BODY_INDENT
    @tag_paragraph = false
    @order         = :index  # | :alpha

    props = []
    keys  = {}
    opts_and_props.flatten!
    opts_and_props.delete_if { |op| 
      if Symbol === op
        props << op; true
      elsif Hash === op
        keys.update(op); true
      else
        false
      end
    }

    props.each { |p|
      case p
      when :posix then @posix = true
      else
        raise(UnknownPropertyError, "Unknown property '#{p.inspect}'.")
      end
    }

#TODO: test this block of code to see if it has tests.
# I'm not sure it is even executed
    keys.each { |k,v|
      case k
      when :unknown_options_action
        if [:collect, :ignore, :raise].include?(v)
          @unknown_options_action = v
        else
          raise(UnknownPropertyError, "Unknown value '#{v}' for "+
                ":unknown_options property.")
        end
      when :command_mode
        @command_mode = v
      when :posix
        @posix = v
#      when :command_options
#        @command_options = v
#        @commands = v.keys
      else
        raise(UnknownPropertyError, "Unknown property '#{k.inspect}'.")
      end
    }
    # :unknown_options => :collect
    # :unknown_options => :ignore
    # :unknown_options => :raise

    opts = opts_and_props

    @options = []
    opts.each { |opt|
      # If user wants to parse posix, then ensure all options are posix
      raise(PosixMismatchError, 
        "Posix types do not match. #{opt.inspect}") if @posix && !opt.posix
      @options << opt
    }

    add_names(@options)

    yield self if block_given?
  end

  #
  #  add_option :names => %w{--file --use-this-file -f},
  #             :
  #
  #  add_option :names              => %w(--version -v),
  #             :arity              => [0,0],  # default
  #             :option_description => "Returns Version"
  #  add_option :names              => %w(--file -f),
  #             :arity              => [1,:unlimited],
  #             :opt_description    => "Define the output filename.",
  #             :arg_description    => "Output file"
  #             :opt_exists         => lambda {}
  #             :opt_not_exists     => lambda {}
  # :option_found
  # :no_option_found
  #             :opt_found          => lambda {}
  #             :no_opt_found       => lambda {}
  #

  #
  # Add an option
  #
  def <<(option)
    @options << option
    add_names(option)
    self
  end

  def add_option(*h)
    opt = Option.new(*h)
    @options << opt
    add_names(opt)
  end

  def add_names(*options)
    options.flatten.each { |option|
      raise "Wrong data type '#{option.name}." unless Option === option
      option.names.each { |name|
        raise(DuplicateOptionNameError,
          "Duplicate option name '#{name}'.") if 
            @opt_lookup_by_any_name.has_key?(name)
        @opt_lookup_by_any_name[name] = option
      }
    }
  end

  def validate_parse_options(h)
    h[:names].each { |name| check_option_name(name) }

    #if @posix
    #  all are single-dash:single-char OR double-dash:multi-char
    #else if unix compliant
    #  single-dash only
    #else any - does not support combination - try to on single/single
    #end
  end

#  def [](opt)
#    @options[@opt_lookup_by_any_name[opt][0]]
#  end

  #
  # Parse the command line
  #
  def parse(argv=ARGV)
    argv = [argv] unless Array === argv

    #
    # Holds the results of each option. The key used is 
    # the first in the :names Array.
    #
    opts = Hash.new( :not_found )

    #
    # A command is the first non-option free argument on the command line.
    # This is a user selection and is the first argument in args.
    #  cmd = args.shift
    # Example:
    #  cvs -v cmd --cmd-option arg
    #
    cmd = nil
    cmd_options = {}

    #
    # #parse_argv yields an array containing the option and its arguments.
    #   [opts, array_args]
    # How do we collect all the arguments when OptionParser deal with an 
    # empty option list
    #
    rslt = parse_argv(argv) { |optarg|
      user_option, _args  = optarg

      m = nil
      if @opt_lookup_by_any_name.has_key?(user_option) ||
         1 == (m = @opt_lookup_by_any_name.keys.grep(/^#{user_option}/)).size
        user_option = m[0] if m
        opt         = @opt_lookup_by_any_name[user_option]
        opt_key     = opt.names[0]

        opt_args = get_opt_args(opt, user_option, _args)
        opts[opt_key] = _cond_dispatch(opt, :opt_found, opt, user_option, opt_args)

        # Collect any remaining args
        @args += _args
      elsif :collect == @unknown_options_action
        @unknown_options << user_option
      elsif :ignore == @unknown_options_action
      else
        raise(UnknownOptionError, "Unknown option '#{user_option}'"+
          "#{$DEBUG ? ' in ' + @opt_lookup_by_any_name.keys.inspect : ''}.")
      end
    }

    #
    # Call :not_found for all the options not on the command line.
    #
    @options.each { |opt|
      name = opt.names[0]
      if :not_found == opts[name]
        opts[name] = _cond_dispatch(opt, :opt_not_found, opt)
      end
    }

    if @command_mode
      cmd = rslt.shift
      @not_parsed = rslt

      OptionData.new(reconstruct_argv(@tagged_options_for_app, nil),
        opts, @unknown_options, @args, @not_parsed, cmd)
    else
      OptionData.new(argv, opts, @unknown_options, @args, @not_parsed, cmd)
    end
  end

  def _cond_dispatch(obj, msg, *args)
    new_obj = obj.send(msg)
    Proc === new_obj ? new_obj.call(*args) : new_obj
  end
  
  def get_opt_args(opt, user_option, _args)
    min, max = *opt.arity
    size     = _args.size

    if (min == max && max > 0 && size < max) || (size < min)
      raise(MissingRequiredOptionArgumentError,
        "Insufficient arguments #{_args.inspect}for option '#{user_option}' "+
        "with :arity #{opt.arity.inspect}")
    end

    if 0 == min && 0 == max
      []
    else
      max = size if -1 == max
      _args.slice!(0..[min, [max, size].min].max - 1)
    end
  end

  def get_posix_re
    flags  = []
    nflags = []
    @options.each { |o| 
      if [0,0] == o.arity 
        flags << o.names[0][1..1] 
      else
        nflags << o.names[0][1..1]
      end
    }
    flags  = flags.join
    flags  = flags.empty? ? "" : "[#{flags}\]+"
    nflags = nflags.join
    nflags = nflags.empty? ? "" : "[#{nflags}\]"
    Regexp.new("^-(#{flags})(#{nflags})(.*)\$")
  end

#######################################################################
  def parse_posix_argv(argv)
    re = @posix ? get_posix_re : Option::GENERAL_OPT_EQ_ARG_RE
    p re if $DEBUG
    tagged = []

    #
    # A Posix command line must have all the options precede
    # non option arguments. For example
    # :names => -h -e -l -p -s
    # where -p can take an argument
    # Command line can read:
    #   -helps  => -h -e -l -p s
    #   -p fred non-opt-arg
    #   -p fred non-opt-arg -h   # not ok
    #   -he -popt-arg1 -popt-arg2 non-opt-arg
    #   -p=fred  # this is not legal?
    #   -pfred  === -p fred
    #

    #"-helps" "-pfred" "-p" "fred"
    #-h -e -l -p [s] -p [fred] -p [fred]
    #[-h, []], [-e []], [-l, []], [-p, [s]], -p

    argv.each { |e| 
      m = re.match(e)
      if m.nil?
        tagged << [:arg, e]
      else
        raise "houston, we have a problem" if m.nil?
        unless m[1].empty?
          m[1].split(//).each { |e| tagged << [:opt, "-#{e}"] }
        end

        unless m[2].empty?
          tagged << [:opt, "-#{m[2]}"]
          tagged << [:arg, m[3]] unless m[3].empty?
        end
      end
    }

if $DEBUG
  print "Tagged:" 
  p tagged
end

    return parse_command_argv(argv, tagged, &block) if @command_mode
    
    #
    # Now, combine any adjacent args such that
    #   [[:arg, "arg1"], [:arg, "arg2"]]
    # becomes
    #   [[:args, ["arg1", "arg2"]]]
    # and the final result should be
    #   [ "--file", ["arg1", "arg2"]]
    #

    parsed = []
    @args  = []
    tagged.each { |e|
      if :opt == e[0]
        parsed << [e[1], []]
      else
        if Array === parsed[-1] 
          parsed[-1][-1] += [e[1]]
        else
          @args << e[1]
        end
      end
    }
    parsed.each { |e| yield e }
  end

  #
  # Seperates options from arguments
  # Does not look for valid options ( or should it? )
  #
  #  %w(-fred file1 file2)    =>    ["-fred", ["file1", "file2"]]
  #  %w(--fred -t -h xyz)     =>    ["--fred", []]   ["-t", []]   ["-h", ["xyz"]]
  #  %w(-f=file)              =>    ["-f", ["file"]]
  #  %w(--file=fred)          =>    ["--file", ["fred"]]
  #  %w(-file=fred)           =>    ["-file", ["fred"]]
  #  ['-file="fred1 fred2"']  =>    ["-file", ["fred1", "fred2"]]
  #
  def parse_argv(argv, &block)
    return parse_posix_argv(argv, &block) if @posix

    @not_parsed = []
    tagged      = []
    argv.each_with_index { |e,i|
      if "--" == e
        @not_parsed = argv[(i+1)..(argv.size+1)]
        break
      elsif "-" == e
        tagged << [:arg, e]
      elsif ?- == e[0]
        m = Option::GENERAL_OPT_EQ_ARG_RE.match(e)
        if m.nil?
          tagged << [:opt, e] 
        else
          tagged << [:opt, m[1]]
          tagged << [:arg, m[2]]
        end
      else
        tagged << [:arg, e]
      end
    }
    # tagged now has defined all options and arguments defined, but
    # does not associate arguments with options and their arity
    # Any non parsed values (after '--') are in the @not_parsed attribute.

    #
    # The tagged array has the form:
    #   [
    #    [:opt, "-a"], [:arg, "filea"], 
    #    [:opt, "-b"], [:arg, "fileb"], 
    #    #[:not_parsed, ["-z", "-y", "file", "file2", "-a", "-b"]]
    #   ]

    return parse_command_argv(argv, tagged, &block) if @command_mode

    #
    # Now, combine any adjacent args such that
    #   [[:arg, "arg1"], [:arg, "arg2"]]
    # becomes
    #   [[:args, ["arg1", "arg2"]]]
    # and the final result should be
    #   [ "--file", ["arg1", "arg2"]]
    #
    # Arity is not considered here.

    parsed = combine_option_and_args(tagged)

    # Yield the options
#    i = 0
    parsed.each_with_index { |e,i| block.call(e) }
#    parsed[i..-1] # don't think this is used now
  end

  def combine_option_and_args(tagged)
    parsed = []
    @args  = []
    tagged.each { |e|
      if :opt == e[0]
        parsed << [e[1], []]
      elsif :arg == e[0]
        if Array === parsed[-1] 
          parsed[-1][-1] += [e[1]]
        else
          @args << e[1]
        end
      else
        raise "How did we get here?"
      end
    }
    parsed
  end
  
  def parse_command_argv(argv, tagged)
    items = tagged.dup
    @tagged_options_for_app = []
    loop {
      break if items.empty?
      type = items[0][0]
      break if type == :arg
      raise "Unknown tagged type '#{type}'." unless type == :opt
      strip_option_and_its_args(items)
    }

    combined_options_and_args = combine_option_and_args(@tagged_options_for_app)

    combined_options_and_args.each { |o| yield o }
    reconstruct_argv(items)
  end

  def strip_option_and_its_args(items)
    @tagged_options_for_app << items.shift
    opt_name = @tagged_options_for_app.last[1]
    arity = @opt_lookup_by_any_name[opt_name].arity
    return items if arity == [0,0]
    
    arg_count = items.inject(0) { |sum, e| e[0] == :arg ? sum + 1 : (break sum) }
    
    raise MissingRequiredOptionArgumentError, "Missing required argument. "+
          "Expected at least #{arity[0]}, found #{arg_count}." if arg_count < arity[0]
    
    [((arity[1] == -1 ? 1.0/0 : arity[1])), items.size, arg_count].
      min.times { @tagged_options_for_app << items.shift }

    items
  end

  def reconstruct_argv(tagged, rest = @not_parsed)
    ary = []
    tagged.each { |type, value| ary.concat [value].flatten  }
    ary.concat @not_parsed unless rest.nil?
    ary
  end
  
  def to_str
    to_s
  end

  def to_s(sep="\n")
    return "" if @options.empty?

    require 'rubygems'
    require 'text/format'
    @f = Text::Format.new
    @f.columns = @columns
    @f.first_indent  = 4
    @f.body_indent   = 8
    @f.tag_paragraph = false

    header = ["OPTIONS\n"]
    s = []
    @options.each { |opt|
      opt_str = []
      if block_given?
        result = yield(opt.names, opt.opt_description, opt.arg_description) 
        if result.kind_of?(String)
          opt_str << result unless result.empty?
        elsif result.nil?
          opt_str << format_option(opt.names, opt.opt_description, opt.arg_description) 
        elsif result.kind_of?(Array) && 3 == result.size
          opt_str << format_option(*result)
        else
          raise "Invalid return value #{result.inspect} from yield block "+
                "attached to #to_s."
        end
      else
        opt_str << format_option(opt.names, opt.opt_description, opt.arg_description)
      end
      s << opt_str.join unless opt_str.empty?
    }
    #s.collect! { |i| i.kind_of?(Array) && /\n+/ =~ i[0] ? i.join : f.paragraphs(i) }
    [header, s].flatten.join(sep)
  end

  def format_option(names, opt_desc, arg_desc)
    # TODO: Clean up the magic numbers

    f = Text::Format.new
    f.columns      = @columns
    f.first_indent = 4
    f.body_indent  = 8
    f.tabstop      = 4
    s = ""
    s << f.format("#{names.join(",")} #{arg_desc}")
    #if 7 == s.last.size
    if 7 == s.size
      f.first_indent = f.first_indent - 2
      s.rstrip!
      s << f.format(opt_desc)
    #elsif 8 == s.last.size
    elsif 8 == s.size
      f.first_indent = f.first_indent - 3
      s.rstrip!
      s << f.format(opt_desc)
    else
      f.first_indent = 2 * f.first_indent
      s << f.format(opt_desc)
    end
  end
  private :format_option

end#class OptionParser

end#module CommandLine
