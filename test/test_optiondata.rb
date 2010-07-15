# $Id: tc_optiondata.rb,v 1.1.1.1 2005/09/08 15:51:38 jdf Exp $
#

require 'test/unit'
require 'commandline/optionparser'

class TC_OptionData < Test::Unit::TestCase
  include CommandLine

  def setup
  end

  def teardown
  end

  def test_option_data
    h = {:one => 1, :proc => lambda {}}
    #new(argv, opts, unknown_options, args, not_parsed, cmd)
    od = OptionData.new([], h, [], [2], [3], [4])
    assert_equal(h, od.instance_variable_get("@opts"))
    assert_equal([2], od.args)
    assert_equal([3], od.not_parsed)
    assert_equal([4], od.cmd)
  end

  def test_base_option_name_reference
    od = OptionParser.new { |o|
      o << Option.new(:flag, :names => %w(--valid --notvalid))
      o << Option.new(:flag, :names => %w(--first --second))
    }.parse(%w(--notvalid --second))
    assert_equal(true, od["--valid"])
    assert_equal(true, od["--first"])
    assert_raises(CommandLine::OptionData::UnknownOptionError) { od["--notvalid"] }
    assert_raises(CommandLine::OptionData::UnknownOptionError) { od["--second"] }
  end

  def test_to_h
    od = OptionParser.new { |o|
      o << Option.new(:flag, :names => "--first")
      o << Option.new(:flag, :names => "--second")
    }.parse(["--first"])

    ans = { "--first" => true, "--second" => false }
    assert_equal(ans, od.to_h)
  end
  
  def test_method_access_to_options
    od = OptionParser.new { |o|
      o << Option.new(:flag, :names => "--first")
      o << Option.new(:flag, :names => "--second")
    }.parse(["--first"])

    assert_nothing_raised { od.first }
    assert_equal(true, od.first)

    assert_nothing_raised { od["--first"] }
    assert_equal(true, od["--first"])
    
    assert_nothing_raised { od.second }
    assert_equal(false, od.second)

    assert_nothing_raised { od["--second"] }
    assert_equal(false, od["--second"])
    
    assert_raises(CommandLine::OptionData::UnknownOptionError) { od.fred }
  end
  
  def test_adding_key
    od = OptionParser.new { |o|
      o << Option.new(:flag, :names => "--first")
      o << Option.new(:flag, :names => "--second")
    }.parse([])

    assert_raises(CommandLine::OptionData::InvalidActionError) { 
        od["--first"] = false }
    assert_nothing_raised { od[:new] = "fred" }
    ans = { "--first" => false, "--second" => false, :new => "fred" }
    assert_equal(ans, od.to_h)
  end
  
end#class TC_OptionData
