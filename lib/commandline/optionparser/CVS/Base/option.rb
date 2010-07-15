#  $Id: option.rb,v 1.1.1.1 2005/09/08 15:51:38 jdf Exp $
#  $Source: /Users/jdf/projects/CVSROOT/devel/ruby/commandline/lib/commandline/optionparser/option.rb,v $
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

module CommandLine

class Option
  class OptionError < StandardError; end
  class InvalidOptionNameError < OptionError; end
  class InvalidArgumentError < OptionError; end
  class MissingOptionNameError < OptionError; end
  class InvalidArgumentArityError < OptionError; end
  class MissingPropertyError < OptionError; end
  class InvalidPropertyError < OptionError; end
  class InvalidConstructionError < OptionError; end

  attr_accessor :posix

  #
  GENERAL_OPT_EQ_ARG_RE  = /^(-{1,2}[a-zA-Z]+[-_a-zA-Z0-9]*)=(.*)$/  # :nodoc:
  GNU_OPT_EQ_ARG_RE      = /^(--[a-zA-Z]+[-_a-zA-Z0-9]*)=(.*)$/
  #OPTION_RE              = /^-{1,2}([a-zA-Z]+\w*)(.*)/
  #UNIX_OPT_EQ_ARG_RE     = /^(-[a-zA-Z])=(.*)$/
  #UNIX_OPT_EQorSP_ARG_RE = /^(-[a-zA-Z])(=|\s+)(.*)$/

  POSIX_OPTION_RE     = /^-[a-zA-Z]?$/
  # need to change this to support - and --
  NON_POSIX_OPTION_RE = /^(-|-{1,2}[a-zA-Z_]+[-_a-zA-Z0-9]*)/

  PROPERTIES = [ :names, :arity, :opt_description, :arg_description,
                 :opt_found, :opt_not_found, :posix
               ]

  FLAG_BASE_OPTS = {
    :arity       => [0,0],
#    :opt_description => nil,
    :arg_description => "",
    :opt_found       => true,
    :opt_not_found   => false
  }

  # You get these without asking for them
  DEFAULT_OPTS = {
    :arity       => [1,1],
    :opt_description => "",
    :arg_description => "",
    :opt_found       => true,
    :opt_not_found   => false
  }

  #
  # Option.new(:flag, :posix => true, :names => %w(--opt))
  #
  # TODO: Should we test and raise key is not one of :names, opt_description, ...
  # This will prevent typos. Can users add properties to an Option that are their own?
  def initialize(*all)
    @posix = false

    raise(MissingPropertyError,
      "No properties specified for new #{self.class}.") if all.empty?

    until Hash === all[0]
      case (prop = all.shift)
      when :flag then @flag = true
      when :posix then @posix = true
      else 
        raise(InvalidPropertyError, "Unknown option setting '#{prop}'.")
      end
    end

    unknown_keys = all[0].keys.find_all { |k| !PROPERTIES.include?(k) && /^use?r_/ !~ "#{k}" }
    raise(InvalidPropertyError, 
      "The key #{unknown_keys.inspect} is not known and is not a user key.") unless 
        unknown_keys.empty?
  
    @flag = nil unless defined?(@flag)
    type = @flag.nil? ? :default : :flag
    merge_hash = 
      case type
      when :flag then FLAG_BASE_OPTS
      when :default then DEFAULT_OPTS
      else raise(InvalidConstructionError, 
        "Invalid arguments to Option.new. Must be a property hash with "+
        "keys [:names, :arity, :opt_description, :arg_description, "+
        ":opt_found, :opt_not_found] or "+
        "an option type [:flag, :default].")
      end

    @properties = {}.merge(merge_hash)
    all.each { |properties|
      raise(InvalidPropertyError, 
        "Don't understand argument of type '#{properties.class}' => "+
            "#{properties.inspect} passed to #{self.class}.new. Looking "+
            "for type Hash.") unless properties.kind_of?(Hash)

      @properties.merge!(properties)
    }
    
    @properties[:names] = [@properties[:names]].flatten.compact

    arg_arity = @properties[:arity]
    @properties[:arity] = [arg_arity, arg_arity] unless 
      arg_arity.kind_of?(Array)

    raise "Invalid value for arity '#{arg_arity}'." unless 
      arg_arity.kind_of?(Array) || arg_arity.kind_of?(Fixnum)

    raise(InvalidArgumentArityError,
      "Conflicting value given to new option: :flag "+
      "and :arity = #{@properties[:arity].inspect}.") if 
        :flag == type && [0,0] != @properties[:arity]

    names = @properties[:names]
    raise(MissingOptionNameError, 
      "Attempt to create an Option without :names defined.") if 
      names.nil? || names.empty?

    names.each { |name| check_option_name(name) }
    validate_arity @properties[:arity]

    create_opt_description if :flag == type
  end

  def create_opt_description
    return if @properties.has_key?(:opt_description)
    word = @properties[:names].grep(/^--\w.+/)
    if word.empty?
      @properties[:opt_description] = ""
    else
      @properties[:opt_description] = "Sets #{word.first[2..-1]} to true."
    end
  end

  def check_option_name(name)
    raise(InvalidOptionNameError, 
      "Option name '#{name}' contains invalid space.") if /\s+/.match(name)

    if @posix
      raise(InvalidOptionNameError, 
        "Option name '#{name}' is invalid.") unless POSIX_OPTION_RE.match(name)
    else
      raise(InvalidOptionNameError, 
        "Option name '#{name}' is invalid.") unless NON_POSIX_OPTION_RE.match(name)
    end
  end

  def validate_arity(arity)
  raise ":arity is nil" if arity.nil?
    min, max = *arity

    raise(InvalidArgumentArityError, "Minimum argument arity '#{min}' must be "+
      "greater than or equal to 0.") unless min >= 0
    raise(InvalidArgumentArityError, "Maximum argument arity '#{max}' must be "+
      "greater than or equal to -1.") if max < -1
    raise(InvalidArgumentArityError, "Maximum argument arity '#{max}' must be "+
      "greater than minimum arity '#{min}'.") if max < min && max != -1
    if @posix
      raise(InvalidArgumentArityError, "Posix options only support :arity "+
        "of [0,0] or [1,1].") unless ([0,0] == arity) || ([1,1] == arity)
    end
  end

  def method_missing(sym, *args)
    raise "Unknown property '#{sym}' for option 
      #{@properties[:names].inspect unless @properties[:names].nil?}." unless 
        @properties.has_key?(sym) || PROPERTIES.include?(sym)
    @properties[sym, *args]
  end

  def to_hash
    Marshal.load(Marshal.dump(@properties))
  end

end#class Option

end#module CommandLine
