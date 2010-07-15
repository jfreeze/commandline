#  $Id: tc_option.rb,v 1.1.1.1 2005/09/08 15:51:38 jdf Exp $
#  $Source: /Users/jdf/projects/CVSROOT/devel/ruby/commandline/test/tc_option.rb,v $
#
#  Author: Jim Freeze
#  Copyright (c) 2005 
#
# =DESCRIPTION
# Test cases for Option Class
#
# =Revision History
#  Jim.Freeze 2005/04/02 Birthday
#

require 'test/unit'
require 'commandline/optionparser'

class TC_Option < Test::Unit::TestCase
  include CommandLine

  def test_flag_parameters
      opt = Option.new(:flag, :names => "-h")
      assert_equal(%w(-h), opt.names)
      assert_equal([0,0],  opt.arity)
      assert_equal("",     opt.opt_description)
      assert_equal("",     opt.arg_description)
      assert_equal(true,   opt.opt_found)
      assert_equal(false,  opt.opt_not_found)
      assert_equal(false,  opt.posix)
  end

  def test_posix
    op = Option.new(:flag, :posix, :names => %w(-))
    assert_equal(true, op.posix)
    op = Option.new(:flag, :names => %w(-))
    assert_equal(false, op.posix)

    assert_raises(CommandLine::Option::InvalidOptionNameError) {
      Option.new(:flag, :posix, :names => %w(--help))
    }
    assert_raises(CommandLine::Option::InvalidOptionNameError) {
      Option.new(:flag, :posix, :names => %w(-help))
    }
    assert_nothing_raised {
      Option.new(:flag, :posix, :names => %w(-h))
    }
    assert_nothing_raised {
      Option.new(:flag, :posix, :names => %w(-H))
    }
    assert_nothing_raised {
      Option.new(:flag, :posix, :names => %w(-))
    }
  end

  def test_no_dash_name
    assert_raises(CommandLine::Option::InvalidOptionNameError) { 
      Option.new(:flag, :names => ["fred"])
    }
  end

  def test_flag_constructor
    opt = nil
    assert_nothing_raised { opt = Option.new(:flag, :names => %w(--debug -d) ) }
    assert_equal("Sets --debug to true.", opt.opt_description)

    opt = Option.new(:flag, 
               :names => %w(--debug -d),
               :opt_description => ""
              )
    assert_equal("", opt.opt_description)

    opt = Option.new(:flag, 
               :names => %w(--debug -d),
               :opt_description => "Custom description"
              )
    assert_equal("Custom description", opt.opt_description)
  end

  def test_block_constructor
    assert_raises(CommandLine::Option::MissingPropertyError) {
      opt = Option.new {  |opp| opp.names = %w(--fred -f) }
    }
  end

  def test_no_arity
    opt = nil
    assert_nothing_raised { opt = Option.new(:flag, :names => %w(--debug -d) ) }
    assert_equal([0,0], opt.arity)
  end

  def test_arity_is_number
    opt = nil
    assert_nothing_raised { opt = 
      Option.new(:names     => %w(--debug -d), 
                 :arity => 1) }
    assert_equal([1,1], opt.arity)

    opt = nil
    assert_nothing_raised { opt = 
      Option.new(:names     => %w(--debug -d), 
                 :arity => 2) }
    assert_equal([2,2], opt.arity)
  end

  def test_names_not_array
    op = nil
    assert_nothing_raised { op = Option.new(:flag, :names => "-fred") }
    assert_equal(["-fred"], op.names)
  end

  def test_arity_is_array
    opt = nil
    assert_nothing_raised { opt = 
      Option.new(:names     => %w(--debug -d), 
                 :arity => [2,3]) }
    assert_equal([2,3], opt.arity)
  end

  def test_incompatible_properties
    assert_raises(CommandLine::Option::InvalidArgumentArityError) { 
      opt = Option.new(:flag, :names => "-a", :arity => 1) }
    assert_raises(CommandLine::Option::InvalidArgumentArityError) { 
      Option.new(:flag, :names => "-b", :arity => 1) }

    assert_raises(CommandLine::Option::InvalidOptionNameError) { 
      Option.new(:posix, :names => "--fred") }
  end

  def test_unknown_properties
    assert_raises(CommandLine::Option::InvalidPropertyError) {
      Option.new(:arg_arity => 1) 
    }

    assert_raises(CommandLine::Option::InvalidPropertyError) {
      Option.new(:names => "-fred", :arg_arity => 1) 
    }
  end

  def test_user_properties
    o = nil
    assert_nothing_raised { o = Option.new(:names => "-fred", :user_fred => "fred") }
    assert_equal("fred", o.user_fred)

    o = nil
    assert_nothing_raised { o = Option.new(:names => "-fred", :usr_fred => "fred") }
    assert_equal("fred", o.usr_fred)
  end

  def test_multiple_hashes
    opt = nil
    assert_nothing_raised { opt = 
      Option.new(:flag,
                 {:names => %w(--debug -d)},
                 {:names => "-fred"}) }
    assert_equal(["-fred"], opt.names)

    assert_nothing_raised { opt = 
      Option.new({:names => %w(debug)},
                 {:names => "-fred"},
                 {:arity => 3}) }
    assert_equal(["-fred"], opt.names)
    assert_equal([3,3], opt.arity)
  end


end#class TC_Option
