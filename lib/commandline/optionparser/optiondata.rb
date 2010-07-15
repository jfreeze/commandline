#  $Id: optiondata.rb,v 1.1.1.1 2005/09/08 15:51:38 jdf Exp $
#  $Source: /Users/jdf/projects/CVSROOT/devel/ruby/commandline/lib/commandline/optionparser/optiondata.rb,v $
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
#

module CommandLine

#
# Data resulting from parsing a command line (Array)
# using a particular OptionParser object
#
class OptionData
  attr_reader :argv, :unknown_options, :args, :not_parsed, :cmd

  class OptionDataError < StandardError; end
  class UnknownOptionError < OptionDataError; end
  class InvalidActionError < OptionDataError; end

  # argv: Original commandline parsed
  # options passed on the commandline?
  # unknown options ??
  # args found on commandline
  # array of arguments that was not parsed -- probably because of '--'
  # the command if in command mode
  def initialize(argv, opts, unknown_options, args, not_parsed, cmd)
    @opts = {}
    opts.each { |k,v| 
      @opts[k] = 
        begin
          Marshal.load(Marshal.dump(v))
        rescue
          v
        end
    }
    @unknown_options = Marshal.load(Marshal.dump(unknown_options))
    @not_parsed = Marshal.load(Marshal.dump(not_parsed))
    @argv = Marshal.load(Marshal.dump(argv))
    @args = Marshal.load(Marshal.dump(args))
    @cmd  = Marshal.load(Marshal.dump(cmd))
  end

  def [](key)
    if @opts.has_key?(key)
      @opts[key]
    else
      raise(UnknownOptionError, "Unknown option '#{key}'.")
    end
  end

  def has_option?(key)
    @opts.has_key?(key)
  end
  
  def []=(key, val)
    raise(InvalidActionError, "Cannot modify existing option data: "+
          "#{key.inspect} => #{val.inspect}") if @opts.has_key?(key)
    @opts[key] = val
  end
  
  def to_h
    Marshal.load(Marshal.dump(@opts))
  end

  # As a convenience, options may be accessed by their name
  # without the dashes. Of course, this won't work for options
  # with names like '--with-shared'. For these names, you must
  # still use option_data['--with-shared']
  def method_missing(sym)
    k1 = "--#{sym}"
    k2 = "-#{sym}"
    if @opts.has_key?(k1)
      @opts[k1]
    elsif @opts.has_key?(k2)
      @opts[k2]
    else
      raise UnknownOptionError, "Unknown option (--|-)#{sym}."
    end
  end
end#class OptionData

end#module CommandLine
