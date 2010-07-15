#  $Id: tc_optionparser.rb,v 1.1.1.1 2005/09/08 15:51:38 jdf Exp $
#  $Source: /Users/jdf/projects/CVSROOT/devel/ruby/commandline/test/tc_optionparser.rb,v $
#
#  Author: Jim Freeze
#  Copyright (c) 2005 Jim Freeze
#
# =DESCRIPTION
# OptionParser test cases
#
# =Revision History
#  Jim.Freeze 04/01/2005 Birthday
#

require 'test/unit'
require 'pp'
require 'commandline/optionparser'

class TC_OptionParser < Test::Unit::TestCase
  include CommandLine

  def setup
    @op = OptionParser.new { |op|
      op << Option.new(:names => %w(--a --b))
    }
  end

  def assert_optionparser_equivalency(op1, op2)
    assert_equal(op1.posix, op2.posix)
    assert_equal(op1.unknown_options_action, op2.unknown_options_action)
    op1.options.zip(op2.options).each { |oop1, oop2|
      assert_option_equivalency(oop1,oop2)
    }
  end

  def assert_option_equivalency(op1, op2)
    assert_equal(op1.names,           op2.names)
    assert_equal(op1.arity,           op2.arity)
    assert_equal(op1.opt_description, op2.opt_description)
    assert_equal(op1.arg_description, op2.arg_description)
    assert_equal(op1.opt_found,       op2.opt_found)
    assert_equal(op1.opt_not_found,   op2.opt_not_found)
  end

  def test_block_construction
    op1 = OptionParser.new { |o|
      o << Option.new(:flag, :names => "--debug")
    }
    op2 = OptionParser.new { |o|
      o.add_option :flag, :names => "--debug"
    }
    assert_optionparser_equivalency(op1, op2)
  end

  def test_no_options
    od = nil
    assert_nothing_raised {
      od = OptionParser.new().parse(%w{})
    }
    assert_equal([], od.args)

    assert_nothing_raised {
      od = OptionParser.new().parse(%w{some_arg})
    }
    assert_equal(["some_arg"], od.args)

    assert_nothing_raised {
      od = OptionParser.new().parse(%w{some_arg some more args})
    }
    assert_equal(["some_arg", "some", "more", "args"], od.args)
  end

  def test_dash
    od = nil
    assert_nothing_raised {
      od = OptionParser.new(Option.new(:flag, :names=>["-d"])).parse(%w{-})
    }
    assert_equal(["-"], od.args)

    od = nil
    assert_nothing_raised {
      od = OptionParser.new().parse(%w{-})
    }
    assert_equal(["-"], od.args)
  end

  def test_long_option_equal
    argv = ["--my-option=Fred is Here."]
  end

  def test_posix_method
    opt = Option.new(:flag, :names => %w(-h))

    op  = OptionParser.new(opt)
    assert_equal(false, op.posix)

    op  = OptionParser.new(opt)
    assert_equal(false, op.posix)

    opt = Option.new(:flag, :posix, :names => %w(-h))
    op  = OptionParser.new(:posix, opt)
    assert_equal(true, op.posix)
  end

  def test_non_posix
    opt = Option.new(:names => "-f", :arity => [1,-1])
    assert_raises(CommandLine::OptionParser::UnknownOptionError) { 
      OptionParser.new(opt).parse(%w(-ffile)) 
    }
  end

  def test_bad_posix_option_with_optionparser
    opt = Option.new(:flag, :names => %w(-help))
    assert_raises(CommandLine::OptionParser::PosixMismatchError) {
      op = OptionParser.new(:posix, opt)
    }
  end

  def test_posix_with_no_space
    opt = Option.new(:posix, 
      :names => %w(-r), 
      :opt_found => OptionParser::GET_ARGS)
    assert_nothing_raised {
      od = OptionParser.new(:posix, opt).parse(["-rubygems"])
      assert_equal("ubygems", od["-r"])
    }
    assert_nothing_raised {
      od = OptionParser.new(:posix, opt).parse(["-r", "ubygems"])
      assert_equal("ubygems", od["-r"])
    }
  end

  def test_posix
    opts = []
    opts << Option.new(:flag, :posix, :names => %w(-h))
    opts << Option.new(:flag, :posix, :names => %w(-e))
    opts << Option.new(:flag, :posix, :names => %w(-l))
    opts << Option.new(:flag, :posix, :names => %w(-p))
    assert_nothing_raised {
      od = OptionParser.new(:posix, opts).parse(["-lelph"])
      assert_equal(true, od["-h"], "for -h")
      assert_equal(true, od["-e"], "for -e")
      assert_equal(true, od["-l"], "for -l")
      assert_equal(true, od["-p"], "for -p")
    }
  end

  def test_ignore_posix
    opt = Option.new(:flag, :posix, :names => %w(-h))
    assert_equal(true, opt.posix)
    assert_nothing_raised { od = OptionParser.new(opt) }
  end

  def test_bad_option_name
    argv = ["-fred"]
    assert_raises(CommandLine::OptionParser::UnknownOptionError) { @op.parse(argv) }
  end

  ### Test parse_argv
  def test_parse_argv
    h = {
      %w(-file file1 file2) => [["-file", ["file1", "file2"]]],
      %w(--file -t -h xyz)  => [["--file", []],   ["-t", []],   ["-h", ["xyz"]]],
      %w(-f=file)           => [["-f", ["file"]]],
      %w(--file=file1)      => [["--file", ["file1"]]],
      %w(-file=file1)       => [["-file", ["file1"]]],
      ["-file=fred1 fred2"] => [["-file", ["fred1 fred2"]]],
      %w(cmd -v file)       => [["-v", ["file"]]],
      %w(-d --file file1 file2 file3 --verbose) => 
                               [["-d", []], 
                               ["--file", ["file1", "file2", "file3"]],
                               ["--verbose", []]],
      %w(-)                 => [["-", []]]
    }

    h.each { |argv, ans|
      res = []
      @op.parse_argv(argv) { |opt_arg| res << opt_arg }
      assert_equal(ans, res,
        "ARGV=#{argv.inspect} yielded #{res.inspect} instead of #{ans.inspect}")
    }
  end

  def test_option_parser_without_options
    argv = %w(one two three)
    od = OptionParser.new.parse(argv)
    assert_equal(argv, od.args, "No match for option_data args")
  end

  def test_empty_option
    assert_raises(CommandLine::Option::MissingPropertyError) {
      Option.new }
  end

  def test_flag
    opt = Option.new(
      :flag,
      :names           => %w(-myflag), 
      :opt_description => "flag desc"
    )
    assert_equal(%w(-myflag), opt.names)
    assert_equal("flag desc", opt.opt_description)
    assert_equal("",          opt.arg_description)
    assert_equal(true,        opt.opt_found)
    assert_equal(false,       opt.opt_not_found)
  end

  def test_get_arg_array_and_get_args
    opt = Option.new(:names => %w(--opt), :opt_found => OptionParser::GET_ARG_ARRAY)
    od  = OptionParser.new(opt).parse(["--opt=file"])
    assert_equal(["file"], od["--opt"])

    od  = OptionParser.new(opt).parse(%w(--opt=file1 --opt file2))
    assert_equal(["file2"], od["--opt"])

    opt = Option.new(:names => %w(-f), :arity => [0,-1],
                     :opt_found => OptionParser::GET_ARG_ARRAY)
    od  = OptionParser.new(opt).parse(%w(-f))
    assert_equal([], od["-f"])
    od  = OptionParser.new(opt).parse(%w(-f file1 -f file2))
    assert_equal(["file2"], od["-f"])
    od  = OptionParser.new(opt).parse(%w(-f file1 file2))
    assert_equal(["file1", "file2"], od["-f"])

    # =======================================================
    opt = Option.new(:names => %w(-f), :arity => [0,-1],
                     :opt_found => OptionParser::GET_ARGS)

    od  = OptionParser.new(opt).parse(["-f"])
    assert_equal(true, od["-f"])

    od  = OptionParser.new(opt).parse(["-f=file"])
    assert_equal("file", od["-f"])

    od  = OptionParser.new(opt).parse(%w(-f file1 file2))
    assert_equal(["file1", "file2"], od["-f"])

    od  = OptionParser.new(opt).parse(%w(-f=file1 file2))
    assert_equal(["file1", "file2"], od["-f"])
  end

  def create_help_option
    o = Option.new( :flag,
      :names           => %w{--help -h}, 
      :opt_description => "Prints this page"
    )
    o
  end

  def create_hi_option
    Option.new(
      :names            => %w{-h -hi --hi}, 
      :arity        => [0,0],
      :arg_description  => "",
      :opt_description  => "Hi",
      :opt_found        => lambda { "hi" },
      :opt_not_found => lambda { "goodbye" }
    )
  end

  def test_config
    help_option = create_help_option
    assert_equal(%w{--help -h}, help_option.names)
    assert_equal([0,0],         help_option.arity)
    assert_equal("",           help_option.arg_description)
    assert_equal("Prints this page",
                                help_option.opt_description)
    assert_equal(TrueClass,     help_option.opt_found.class)
    assert_equal(FalseClass,    help_option.opt_not_found.class)
  end

  def test_duplicate_name
    help_option = nil
    op          = nil
    assert_nothing_raised() { help_option = create_help_option }
    assert_nothing_raised() { op = OptionParser.new }
    assert_raises(OptionParser::DuplicateOptionNameError) { 
      op << help_option
      op << help_option # this should raise
    }
  end

  def test_duplicate_name2
    help_option = create_help_option
    hi_option   = create_hi_option

    op = OptionParser.new
    op << help_option

    assert_raises(OptionParser::DuplicateOptionNameError) { 
      op << hi_option
    }
  end

  def test_empty
    argv = []
    od   = OptionParser.new.parse(argv)
    assert_equal(OptionData, od.class)
  end

  def test_help
    help_option = create_help_option
    op = OptionParser.new(help_option)

    od = op.parse([])
    assert_equal(false, od["--help"])

    od = op.parse(["-h"])
    assert_equal(true, od["--help"])
    assert_raises(OptionData::UnknownOptionError) { od["-h"] }

    od = op.parse(["--help"])
    assert_equal(true, od["--help"])
    assert_raises(OptionData::UnknownOptionError) { od["-h"] }
  end

  def test_option_data_bad_key
    help_option = create_help_option
    od = OptionParser.new(help_option).parse("")
    assert_nothing_raised { od["--help"] }
    assert_raises(OptionData::UnknownOptionError) { od["-h"] }
  end

  def test_multiple
    opt = Option.new( 
      :names           => %w{--file -f}, 
      :arity       => [2,2], 
      :arg_description => "file", 
      :opt_description => "reads file",
      :opt_found       => lambda { |opt, user_opt, args| args },
      :opt_not_found   => lambda { |opt| raise }
    )
    od = OptionParser.new(opt).parse(%w{-f file1 file2 file3})
    assert_equal(%w{file1 file2}, od["--file"])
    assert_equal(%w{file3}, od.args)
  end

  def test_opts_only_with_no_getargs
    opts = []
    opts << Option.new(:names => "--name")
    od = OptionParser.new(opts).parse(%w(--name fred))

    assert_equal([], od.args, "Args should be [].")
    assert_equal(true, od["--name"])
  end
  
  def test_no_action
    opt = Option.new( 
      :names           => %w{--file -f}, 
      :arity       => [1,1], 
      :opt_description => "reads file",
      :arg_description => "file", 
      :opt_found       => lambda { |opt, user_opt, args| [opt.names, user_opt, args] },
      :opt_not_found   => lambda { :not_found }
    )
    od1 = OptionParser.new(opt).parse([])
    od2 = OptionParser.new(opt).parse(%w{--file file})

    assert_equal(:not_found, od1["--file"])
    assert_equal([["--file", "-f"], "--file", ["file"]], od2["--file"])
  end

  def test_unknown_option
    assert_raises(CommandLine::OptionParser::UnknownOptionError) { 
      OptionParser.new(create_help_option).parse(%w{-file})
    }
  end

  def test_arity_1
    opts = Option.new( 
      :names           => %w{--file -file -f}, 
      :arity           => [1,1],
      :opt_description => "reads file",
      :arg_description => "file",
      :opt_found       => lambda { |opt, user_opt, args| 
        assert_equal("--file", opt.names.first)
        assert_equal("-f", user_opt)
        assert_equal(["the_file"], args)
        :return
      },
      :opt_not_found   => nil
    )

    op = OptionParser.new(opts)
    od = op.parse(%w{-f the_file})

    assert_equal(:return, od["--file"])
  end

  def test_parse_argv
    op  = OptionParser.new
    a   = []
    blk = lambda { |e| a << e }

    a   = []
    op.method(:parse_argv).call(%w{-f file1 file2 -z}, &blk)
    assert_equal([["-f", ["file1", "file2"]], ["-z", []]], a)

    a   = []
    op.method(:parse_argv).call(%w{-f file2 -z}, &blk)
    assert_equal([["-f", ["file2"]], ["-z", []]], a)

    a   = []
    op.method(:parse_argv).call(%w{-f file}, &blk)
    assert_equal([["-f", ["file"]]], a)

    a   = []
    op.method(:parse_argv).call(%w{-f file2 -z}, &blk)
    assert_equal([["-f", ["file2"]], ["-z", []]], a)

    a   = []
    op.method(:parse_argv).call(%w{-f -z file}, &blk)
    assert_equal([["-f", []], ["-z", ["file"]]], a)

    a   = []
    op.method(:parse_argv).call(%w{-f -z file -z}, &blk)
    assert_equal([["-f", []], ["-z", ["file"]], ["-z", []]], a)

    a   = []
    op.method(:parse_argv).call(%w{-f file -}, &blk)
    assert_equal([["-f", ["file", "-"]]], a)

    a   = []
    op.method(:parse_argv).call(%w{- --file file}, &blk)
    assert_equal([["--file", ["file"]]], a)

    a   = []
    op.method(:parse_argv).call(%w{mycell myview -lib mylib -whatever}, &blk)
    assert_equal([["-lib", ["mylib"]], ["-whatever", []]], a)
    assert_equal(%w{mycell myview}, op.instance_variable_get("@args"))
  end

  def test_bad_option_1
    opts = []
    opts << Option.new( 
      :names           => %w{--file -f}, 
      :arity       => [1,-1], 
      :opt_description => "a", 
      :arg_description => "b",
      :opt_found       => lambda {|opt, user_opt, args| [opt, args] }, 
      :opt_not_found   => nil
    )
    opts << Option.new( 
      :names           => %w{--help -h}, 
      :arity       => [0,0], 
      :opt_description => "a", 
      :opt_description => "b",
      :opt_found       => "help", 
      :opt_not_found   => nil
    )

    op = OptionParser.new(opts)
    op.parse(%w{-f file})
    assert_raises(OptionParser::MissingRequiredOptionArgumentError) {
      op.parse(%w{-f -h})
    }
  end

  def test_bad_option_2
    opts = []
    opts << Option.new( 
      :names           => %w{--file1 -f1}, 
      :arity       => [3,4], 
      :opt_description => "a", 
      :arg_description => "b",
      :opt_found       => lambda {|opt, user_opt, args| [opt.names.first, args] }, 
      :opt_not_found   => nil
    )
    opts << Option.new( 
      :names           => %w{--file2 -f2}, 
      :arity       => [0,1], 
      :opt_description => "a", 
      :arg_description => "b",
      :opt_found       => lambda {|opt, user_opt, args| [opt.names.first, args] }, 
      :opt_not_found   => nil
    )
    opts << Option.new( 
      :names           => %w{--help -h}, 
      :arity       => [0,0], 
      :opt_description => "a", 
      :arg_description => "b",
      :opt_found       => "help", 
      :opt_not_found   => nil
    )

    od = nil
    op = OptionParser.new(opts)
    assert_raises(OptionParser::MissingRequiredOptionArgumentError) { 
      op.parse(%w{-f1 file}) 
    }
    assert_raises(OptionParser::MissingRequiredOptionArgumentError) { 
      op.parse(%w{-f1 file file}) 
    }
    assert_nothing_raised(OptionParser::MissingRequiredOptionArgumentError) { 
      od = op.parse(%w{-f1 file1 file2 file3}) 
    }
    assert_equal(["--file1", %w{file1 file2 file3}], od["--file1"])

    assert_nothing_raised(OptionParser::MissingRequiredOptionArgumentError) { 
      od = op.parse(%w{-f1 file file file file}) 
    }
    assert_equal(["--file1", %w{file file file file}], od["--file1"])

    assert_nothing_raised(OptionParser::MissingRequiredOptionArgumentError) { 
      od = op.parse(%w{-f1 file file file file ugh}) 
    }
    assert_equal(["--file1", %w{file file file file}], od["--file1"])
    assert_equal(["ugh"], od.args)

    assert_equal(%w{-f1 file file file file ugh}, od.argv)
  end

  def test_bad_name_def
    assert_raises(Option::InvalidOptionNameError) {
      Option.new( 
        :names           => "name", 
        :arity       => [0,0], 
        :opt_description => "a", 
        :arg_description => "b", 
        :opt_found       => "help", 
        :opt_not_found   => nil)
    }
  end

  def test_bad_option_name
    assert_raises(Option::InvalidOptionNameError) {
      Option.new( 
        :names           => %w{name}, 
        :arity       => [0,0], 
        :opt_description => "a", 
        :arg_description => "b", 
        :opt_found       => "help", 
        :opt_not_found   => nil)
    }
    assert_raises(Option::InvalidOptionNameError) {
      Option.new( 
        :names           => %w{-name f}, 
        :arity       => [0,0], 
        :opt_description => "a", 
        :arg_description => "b", 
        :opt_found       => "help", 
        :opt_not_found   => nil)
    }
  end

  def test_bad_arity
    assert_raises(Option::InvalidArgumentArityError) {
      Option.new( 
        :names           => %w{-file}, 
        :arity       => [-1,0], 
        :opt_description => "a", 
        :arg_description => "b", 
        :opt_found       => "help", 
        :opt_not_found   => nil)
    }
    assert_raises(Option::InvalidArgumentArityError) {
      Option.new( 
        :names           => %w{-file}, 
        :arity       => [1,0], 
        :opt_description => "a", 
        :arg_description => "b", 
        :opt_found       => "help", 
        :opt_not_found   => nil)
    }
    assert_raises(Option::InvalidArgumentArityError) {
      Option.new( 
        :names           => %w{-file}, 
        :arity       => [4,3], 
        :opt_description => "a", 
        :arg_description => "b", 
        :opt_found       => "help", 
        :opt_not_found   => nil)
    }
    assert_raises(Option::InvalidArgumentArityError) {
      Option.new( 
        :names           => %w{-file}, 
        :arity       => [4,-3], 
        :opt_description => "a", 
        :arg_description => "b", 
        :opt_found       => "help", 
        :opt_not_found   => nil)
    }
  end

  def test_extra_option
    opts = []
    opts << Option.new(
      :names           => %w{-lib}, 
      :arity       => [1,1], 
      :opt_description => "lib cell", 
      :arg_description => "lib", 
      :opt_found       => lambda { |opt, userr_opt, args| args }, 
      :opt_not_found   => []
    )
    opts << Option.new(
      :flag,
      :names           => %w{-whatever}, 
      :opt_description => "whatever flag"
    )

    argv = %w{mycell myview -lib mylib -whatever}
    od = OptionParser.new(opts).parse(argv)

    assert_equal(%w{mycell myview}, od.args)
    assert_equal(%w{mylib},         od["-lib"])
    assert_equal(true,              od["-whatever"])
  end

  def test_to_s_1
    opts = []
    opts << Option.new(
      :names           => %w{--file -file -f}, 
      :opt_description => "File to open", 
      :arg_description => "file"
      #:opt_found       => nil, 
      #:opt_not_found   => nil
    )
    opts << Option.new(
      :flag,
      :names           => %w{--help -h}, 
      :opt_description => "Displays this help text.", 
      :arg_description => ""
    )
    opts << Option.new(
      :flag,
      :names           => %w{-x}, 
      :opt_description => "Single character options desc. goes on same line."
    )
    opts << Option.new(
      :flag,
      :names           => %w{--x},
      :opt_description => "Double dash and single character options desc. goes "+
                          "on the same line."
    )
    opts << Option.new(
      :names           => %w{---x},
      :opt_description => "Triple dash and single character desc. goes on the "+
                          "next line."
    )
    opts << Option.new(
      :flag,
      :names           => %w{--y},
      :opt_description => "Double dash and single character options description "+
                          "that wraps to the next line."
    )
    opts << Option.new(
      :flag,
      :names           => %w{--extract},
      :opt_description => "Single word option goes on next line."
    )
    opts << Option.new(
      :flag,
      :names           => %w{-u},
      :opt_description => "Uses time of last access instead of last modification "+
                          "for sorting (with the -t option) or printing (with the "+
                          "-l option)."
    )
    opts << Option.new(
      :names           => %w{-s}, 
      :arity       => [1,2],
      :arg_description => "type [type2]", 
      :opt_description => "In Xanadu did Kubla Khan A stately pleasure dome "+
                          "decree Where Alph the sacred river, ran Through "+
                          "caverns measureless to man Down to a sunless sea."
    )
    opts << Option.new(
      :names           => %w{-l},
      :arity       => [4,4],
      :arg_description => "file1 file2 file3 file4", 
      :opt_description => "Same line text will run over."
    )

    ans = <<-EOF
OPTIONS

    --file,-file,-f file
        File to open

    --help,-h
        Displays this help text.

    -x  Single character options desc. goes on same line.

    --x Double dash and single character options desc. goes on the same line.

    ---x
        Triple dash and single character desc. goes on the next line.

    --y Double dash and single character options description that wraps to
        the next line.

    --extract
        Single word option goes on next line.

    -u  Uses time of last access instead of last modification for sorting
        (with the -t option) or printing (with the -l option).

    -s type [type2]
        In Xanadu did Kubla Khan A stately pleasure dome decree Where
        Alph the sacred river, ran Through caverns measureless to man
        Down to a sunless sea.

    -l file1 file2 file3 file4
        Same line text will run over.
    EOF

    ans2 = <<-EOF
OPTIONS
    --file,-file,-f file
        File to open
    --help,-h
        Displays this help text.
    -x  Single character options desc. goes on same line.
    --x Double dash and single character options desc. goes on the same line.
    ---x
        Triple dash and single character desc. goes on the next line.
    --y Double dash and single character options description that wraps to
        the next line.
    --extract
        Single word option goes on next line.
    -u  Uses time of last access instead of last modification for sorting
        (with the -t option) or printing (with the -l option).
    -s type [type2]
        In Xanadu did Kubla Khan A stately pleasure dome decree Where
        Alph the sacred river, ran Through caverns measureless to man
        Down to a sunless sea.
    -l file1 file2 file3 file4
        Same line text will run over.
    EOF

    desc = OptionParser.new(opts).to_s
    adescopt = desc.split(/\n/)
    aans = ans.rstrip.split(/\n/)
    lines = []
    adescopt.each_with_index { |r,i| 
      lines << sprintf("%-2d|", i)
      lines << r << "\n"
    }
#puts desc
    aans.each_with_index { |line, i|
      assert_equal(line, adescopt[i], "Option Description not equivalent on "+
                                   "line #{i}.\n"+ lines.join)
    }

    desc = OptionParser.new(opts).to_s("")
    adescopt = desc.split(/\n/)
    aans = ans2.chomp.split(/\n/)
    lines = []
    adescopt.each_with_index { |r,i| 
      lines << sprintf("%-5d", i)
      lines << r << "\n"
    }
    aans.each_with_index { |line, i|
      assert_equal(line, adescopt[i], "Option Description not equivalent on "+
                                   "line #{i}.\n"+ lines.join)
    }
  end

  def test_required_option
    opts = [ Option.new(
      :names           => %w(--opt -o),
      :arity       => [3,3],
      :arg_description => "arg1 arg2 arg3", 
      :opt_description => "testing opt and arg errors.",
      :opt_found       => nil, 
      :opt_not_found   => OptionParser::OPT_NOT_FOUND_BUT_REQUIRED)
    ]

    assert_raises(OptionParser::MissingRequiredOptionError) {
      OptionParser.
      new(opts).
      parse([])
    }

    begin
      OptionParser.new(opts).parse([])
    rescue => err
      assert_equal("Missing required parameter '--opt'.", err.to_s) 
    end
  end

  def test_custom_option_desc
    opts = []
    opts << Option.new(
      :names           => %w{--file -f}, 
      :arity       => [4,4], 
      :arg_description => "file1 file2 file3 file4", 
      :opt_description => "Same line text will run over.",
      :opt_found       => nil,
      :opt_not_found   => OptionParser::OPT_NOT_FOUND_BUT_REQUIRED
    )
    opts << Option.new(
      :names           => %w{--text -t}, 
      :arity       => [1,1], 
      :arg_description => "text", 
      :opt_description => "Supply a text string.",
      :opt_found       => nil, 
      :opt_not_found   => OptionParser::OPT_NOT_FOUND_BUT_REQUIRED
    )

    called = :not_called
    pass   = 1
    #
    # ""     #=>  not used
    # nil    #=> use default
    # "blah" #=> users custom output
    # [opts, ad, od] #=> uses internal formatting with user updated params
    #
    desc = OptionParser.new(opts).to_s {  |names, opt_desc, arg_desc|
      called = :called
      if 1 == pass
        assert_equal(%w{--file -f}, names)
        assert_equal("file1 file2 file3 file4", arg_desc)
        assert_equal("Same line text will run over.", opt_desc)
      else
        assert_equal(%w{--text -t}, names)
        assert_equal("text", arg_desc)
        assert_equal("Supply a text string.", opt_desc)
      end
      pass += 1
      nil
    }
    assert_equal(:called, called)
    ans = <<-EOF
OPTIONS

    --file,-f file1 file2 file3 file4
        Same line text will run over.

    --text,-t text
        Supply a text string.
    EOF
    assert_equal(ans, desc)

    desc = OptionParser.new(opts).to_s {  |names, opt_desc, arg_desc|
      if names.include?("--text")
        [names.collect { |n| n.upcase}, "my desc", "put_arg_desc_here"]
      else
        ""
      end
    }
    ans = <<-EOF
OPTIONS

    --TEXT,-T put_arg_desc_here
        my desc
    EOF
    assert_equal(ans, desc)
  end
  
  def test_get_args
    opts = []
    opts << Option.new( 
      :names           => %w{-t1}, 
      :arity       => [1,-1],
      :opt_description => "test1",
      :arg_description => "case", 
      :opt_found       => OptionParser::GET_ARGS, 
      :opt_not_found   => nil
    )
    opts << Option.new( 
      :names           => %w{-t2}, 
      :arity       => [0,0],
      :opt_description => "test2",
      :arg_description => "", 
      :opt_found       => OptionParser::GET_ARGS, 
      :opt_not_found   => nil
    )
    parser = OptionParser.new( opts )
    data1  = parser.parse( %w{-t1 a buncha stuff} )
    assert_equal(%w{a buncha stuff}, data1["-t1"])
    data2  = parser.parse( %w{-t1 one} )
    assert_equal("one", data2["-t1"] )
    data3  = parser.parse( "-t2" )
    assert_equal(true, data3["-t2"])
  end
  
  def test_required_args
    opts = []
    opts << Option.new( 
              :names => %w{-t1 }, 
              :arity => [1,-1],
              :opt_description => "test1",
              :arg_description => "case", 
              :opt_found       => OptionParser::GET_ARGS,
              :opt_not_found   => nil 
            )
    opts << Option.new(
              :names => %w{-t2}, 
              :arity => [0,0],
              :opt_description => "test2",
              :arg_description => "", 
              :opt_found       => OptionParser::GET_ARGS,
              :opt_not_found   => OptionParser::OPT_NOT_FOUND_BUT_REQUIRED
            )
    parser = OptionParser.new( opts )
    assert_raises( OptionParser::MissingRequiredOptionError ){
      parser.parse( %w{-t1 option} )
    }
    data = nil
    assert_nothing_raised(){
      data = parser.parse( %w{-t1 option -t2} )
    }
    assert_equal("option", data["-t1"])
    assert_equal(true, data["-t2"])
  end
  
  def test_multi_use
    opts = []
      #:opt_arity => ":overwrite | :error | :warning | :append"
    opts << Option.new( 
      :names           => %w{-c}, 
      :arity       => [1,1],
      :arg_description => "config",
      :opt_description => "Config options. May be used multiple times.",
      :opt_found       => lambda { |opt, user_opt, args| @c << args[0] },
      :opt_not_found   => lambda { puts "-c not called" }
    )
    parser = OptionParser.new( opts )

# could put a number of times opt_found is called in the lambda
    @c = []
    parser.parse(%w{-c config1 -c config2 -c config3})
    assert_equal(%w{config1 config2 config3}, @c)
  end

  def test_arity_0
    opts = []
    opts   << Option.new( 
      :flag,
      :names           => %w{--debug -d}, 
      :opt_description => "test1"
    )

    parser = OptionParser.new( opts )
    od     = parser.parse(%w{-d r9t-3r.csv})
    assert_equal(["r9t-3r.csv"], od.args, "Failed with arg after -d flag.")
    od     = parser.parse(%w{-d arg1 arg2})
    assert_equal(%w{arg1 arg2}, od.args, "Failed with args after -d flag.")

    opts = []
    opts   << Option.new( 
      :flag,
      :names           => %w{-d --debug}, 
      :opt_description => "test1"
    )

    parser = OptionParser.new( opts )
    od     = parser.parse(%w{-d r9t-3r.csv})
    assert_equal(["r9t-3r.csv"], od.args, "Failed with -d defined as first arg.")

    od     = parser.parse(%w{-d arg1 arg2 arg3})
    assert_equal(%w{arg1 arg2 arg3}, od.args)
    assert_equal(true, od["-d"])
    od     = parser.parse(%w{arg1 -d arg2 arg3})
    assert_equal(%w{arg1 arg2 arg3}, od.args)
    od     = parser.parse(%w{arg1 arg2 -d arg3})
    assert_equal(%w{arg1 arg2 arg3}, od.args)
    od     = parser.parse(%w{arg1 arg2 arg3 -d})
    assert_equal(%w{arg1 arg2 arg3}, od.args)
  end

  def test_invalid_property_error
    assert_raises(CommandLine::Option::InvalidPropertyError) {
      # note the missing key ':names =>'
      Option.new(:flag, %w(--verbose -v))
    }
  end

  def test_command_mode

# Decision: If we put methods into the user app to handle commands
# how does OptionParser know to call these methods?
# That is what we must solve.
# Probably have to get an instance of the app into the parser.

    # This should return two sets of option data....how to we handle this?
=begin
    op = OptionParser.new(app_opt, :command_options => commands)
    op.parse(%w(-d ext_path update -r .))
    case od.cmd
      when 'update'
      odu = OptionParser.new(cmd_update_opt).parse(od.args)
      when 'edit'
      odu = OptionParser.new(cmd_update_opt).parse(od.args)
      when 'history'
      odu = OptionParser.new(cmd_update_opt).parse(od.args)
    end
=end
  end

  def test_greedy_match
    opts = []
    opts << Option.new(:flag, :names => "-abcdeeee")
    opts << Option.new(:flag, :names => "-abaaaaaa")

    od = nil
    assert_nothing_raised {
      od = OptionParser.new(opts).parse("-aba")
    }
    assert_equal(true,  od["-abaaaaaa"])
    assert_equal(false, od["-abcdeeee"])
  end

  def test_unknown_options
    op = nil
    assert_nothing_raised {
      op = OptionParser.new(:unknown_options_action => :collect)
    }
    od = nil
    assert_nothing_raised {
      od = op.parse("-fred")
    }
    assert_equal(["-fred"], od.unknown_options)
  end

  def test_isolated_double_dash
    opts = []
    opts << Option.new(:names => "-a")
    opts << Option.new(:names => "-b", :opt_found => OptionParser::GET_ARGS)

    od = nil
    argv = %w(-a filea -b fileb -- -z -y file file2 -a -b)
    assert_nothing_raised {
      od = OptionParser.new(opts).parse(argv)
    }

    assert_equal(true,    od["-a"])
    assert_equal("fileb", od["-b"])

    assert_equal(%w{-z -y file file2 -a -b}, od.not_parsed)
  end

  def assert_option_data_equivalency(od1, od2)
    assert_equal(od1.argv, od2.argv)
    assert_equal(od1.args, od2.args)
    assert_equal(od1.unknown_options, od2.unknown_options)
    assert_equal(od1.cmd, od2.cmd)
  end

  def xtest_dash_s_compatible
    # this is dumb
    argv = %w(-a -b file file2)
    od1 = OptionParser.simple(:dash_s, argv)
    ARGV.shift until ARGV.empty? 
    ARGV.concat argv
    od2 = OptionParser.new(:dash_s)
    assert_option_data_equivalency(od1, od2)

    argv = %w(-a -b -- -c file file2)
    od1 = OptionParser.simple(:dash_s, argv)
    ARGV.shift until ARGV.empty? 
    ARGV.concat argv
    od2 = OptionParser.simple(:dash_s)
    assert_option_data_equivalency(od1, od2)

    argv = %w(file -a -b file2)
    od1 = OptionParser.simple(:dash_s, argv)
    ARGV.shift until ARGV.empty? 
    ARGV.concat argv
    od2 = OptionParser.simple(:dash_s)
    assert_option_data_equivalency(od1, od2)
  end

  module WEBrick; end
  module WEBrick::Daemon; end
  module WEBrick::SimpleServer; end
 
  def test_server_example
    # Replicate the following:
    #
    # require 'optparse'
    # 
    # OPTIONS = {
    #   :port        => 3000,
    #   :ip          => "0.0.0.0",
    #   :environment => "development",
    #   :server_root => File.expand_path(File.dirname(__FILE__) + "/../public/"),
    #   :server_type => WEBrick::SimpleServer
    # }
    # 
    # ARGV.options do |opts|
    #   script_name = File.basename($0)
    #   opts.banner = "Usage: ruby #{script_name} [options]"
    # 
    #   opts.separator ""
    # 
    #   opts.on("-p", "--port=port", Integer,
    #           "Runs Rails on the specified port.",
    #           "Default: 3000") { |OPTIONS[:port]| }
    #   opts.on("-b", "--binding=ip", String,
    #           "Binds Rails to the specified ip.",
    #           "Default: 0.0.0.0") { |OPTIONS[:ip]| }
    #   opts.on("-e", "--environment=name", String,
    #           "Specifies the environment to run this server "+
    #           "under (test/development/production).",
    #           "Default: development") { |OPTIONS[:environment]| }
    #   opts.on("-d", "--daemon",
    #           "Make Rails run as a Daemon (only works if fork is "+
    #           "available -- meaning on *nix)."
    #           ) { OPTIONS[:server_type] = WEBrick::Daemon }
    # 
    #   opts.separator ""
    # 
    #   opts.on("-h", "--help",
    #           "Show this help message.") { puts opts; exit }
    # 
    #   opts.parse!
    # end
    # 

    opts = []
    opts << Option.new(:names           => %w(--port -p), 
                       :opt_description => "Runs Rails on the specified port.",
                       :arg_description => "port",
                       :opt_found       => lambda { |opt, uopt, args| args.to_i },
                       :opt_not_found   => 3000)

    opts << Option.new(:names           => %w(--binding -b),
                       :opt_description => "Binds Rails to the specified ip.",
                       :arg_description => "ip",
                       :opt_found       => OptionParser::GET_ARGS,
                       :opt_not_found   => "0.0.0.0")

    opts << Option.new(:names           => %w(--environment -e), 
                       :opt_description => "Specifies the environment to run "+
                                           "this server under "+
                                           "(test/development/production).",
                       :arg_description => "name",
                       :opt_found       => OptionParser::GET_ARGS,
                       :opt_not_found   => "development")

    opts << Option.new(:names           => %w(--daemon -d),
                       :opt_description => "Make Rails run as a Daemon (only "+
                                           "works if fork is available -- meaning "+
                                           "on *nix).",
                       :arg_description => "server_type",
                       :opt_found       => WEBrick::Daemon,
                       :opt_not_found   => WEBrick::SimpleServer)

    opts << Option.new(:names           => %w(--help -h),
                       :opt_description => "Show this help message.",
                       :opt_found       => lambda { puts @tmp_op.to_s; exit })
    
    @tmp_op = OptionParser.new(opts)# .parse
    #puts
    #puts @tmp_op
  end

  def test_cvs_like_command
=begin
    {
      cvs   --help command

      :add    => # cvs add [-k rcs-kflag] [-m message] files
        [
          Option.new(
            :names => "-k",
            :arg_description => "rcs-kflag"),
          Option.new(
            :names => "-m",
            :arg_description => "message")
        ],

      :admin  =>  # cvs admin [rcs-options] files
      :diff   =>  # cvs diff [-lR] [-D d1] [-N] [-r rev] [--ifdef=arg]

      #:edit   => ,
      #:rtag   => ,
      #:status => ,
      #:unedit => ,
      #:update => %w(-r -p),

    opts << Option.new(
      :names           => %w(--help -h),
      :opt_description => "Show this help message.",
      :opt_found       => lambda { puts @tmp_op.to_s; exit }
    )
=end
  end

  def test_posix_print
    #assert_equal(true, false)
    # should be able to test
    # flags -c -a -b
    # printed a usage line
    # [-abc] [-r rev]
  end

  # I don't think we are going to support this.
  def xtest_temp21
    OptionParser.new(
     :names => %w(--file -file --files -files -f),
     :arity => [1,-1],
     :arg_description => "file1 [file2, ...]")

  end


end#class TC_OptionParser

