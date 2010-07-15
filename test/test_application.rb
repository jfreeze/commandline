
require 'test/unit'
require 'test/unit/systemtest'
require 'commandline'

class TestApplication < Test::Unit::TestCase

  def setup
    # This is dumb and should be fixed
    @apps = Dir["data/app*.rb"]
    def @apps.[](val)
      self.find { |a| "data/app#{val}.rb" == a }
    end
    
    @apps.collect!  { |a| "ruby -I../lib #{a}" }

    @eapps = Dir["data/eapp*.rb"]
    @eapps.collect! { |app| "ruby -I../lib #{app}" }
  end

  ANS  = Hash.new { |h,k| h[k] = {} }
  EANS = Hash.new { |h,k| h[k] = {} }
#--------------------------------------------------------------
  ANS[:app1][:args] = nil
  ANS[:app1][:stdout] = " Usage: app1.rb [-dv] [-f output_file] other_stuff\n"
=begin
  <<-EOT
NAME

    data/app1.rb

OPTIONS

    --version,-v
        Prints version - 0.1

    --file,-f output_file

    --debug,-d
        Prints backtrace on errors and debug status to stdout.
  EOT
=end
  ANS[:app1][:stderr] = ""

#--------------------------------------------------------------
  ANS[:app2][:args]   = nil
  ANS[:app2][:stdout] = " Usage: app2.rb \n"
  ANS[:app2][:stderr] = ""
#--------------------------------------------------------------
  ANS[:app3][:args]   = nil
  ANS[:app3][:stdout] = " Usage: app3.rb [-v] [-f output_file] other_stuff\n"
  ANS[:app3][:stderr] = ""
#--------------------------------------------------------------
  ANS[:app4][:args]   = nil
  ANS[:app4][:stdout] = " Usage: app4.rb [-dv] [-f output_file] other_stuff\n"
  ANS[:app4][:stderr] = ""
#--------------------------------------------------------------
  ANS[:app5][:args]   = nil
  ANS[:app5][:stdout] = " Usage: app5.rb \n"
  ANS[:app5][:stderr] = ""
#--------------------------------------------------------------
  ANS[:app6][:args]   = nil
  ANS[:app6][:stdout] = " Usage: app6.rb \n"
  ANS[:app6][:stderr] = ""
#--------------------------------------------------------------
  ANS[:app7][:args]   = nil
  ANS[:app7][:stdout] = " Usage: app7.rb \n"
  ANS[:app7][:stderr] = ""
#--------------------------------------------------------------
  ANS[:app8][:args]   = %w(file1 file2)
  ANS[:app8][:stdout] = ""
  ANS[:app8][:stderr] = ""
#--------------------------------------------------------------
  ANS[:app9][:args]   = %w(file1 file2)
  ANS[:app9][:stdout] = "running\n"
  ANS[:app9][:stderr] = ""
#--------------------------------------------------------------
#--------------------------------------------------------------
  ANS[:app11][:args]   = ""
  ANS[:app11][:stdout] = " Usage: app11.rb \n"
  ANS[:app11][:stderr] = ""
#--------------------------------------------------------------
  def teardown
  end

  def app_test(app)
    num = /app(\d+)/.match(app)[1].to_i
    return if num > 11
    sym = /(app\d+)/.match(app)[1].to_sym

    puts "===> Testing App: #{app}"
    assert_success(app, ANS[sym][:args]) { |out, err, status|
      assert_equal(ANS[sym][:stdout], out, "STDOUT incorrect for #{app}.")
      assert_equal(ANS[sym][:stderr], err, "STDERR incorrect for #{app}.")
    }
  end

  def test_apps
    @apps.each { |app| app_test app }
  end

  def test_eapps
    @eapps.each { |path|
      app = File.basename(path, ".rb").to_sym
      assert_failure(path, EANS[app][:args]) { |out, err, status|
        assert_equal(EANS[app][:stdout], out, "STDOUT incorrect for #{path}.")
        assert_equal(EANS[app][:stderr], err, "STDERR incorrect for #{path}.")
      }
    }
  end

  # =Replay
  # Replay stores the command line in a .replay file
  # in the working directory from which the app was launched.
  # Relaunching the app with -r uses the arguments from the
  # .replay file, saving typing and mistakes.
  # Without the -r flag, any existing replay file is overwritten
  # with the arguments sent to the application. If no arguments
  # are sent, the .replay file is left untouched.
  # If the -r flag is provided with other arguments, they are
  # ignored if @replay is set.
  def test_replay
    path = 'ruby -I../lib data/app12.rb'
    File.delete(".replay") if File.exists?(".replay")
    
    ans = {}
    ans[:args]   = ""
    ans[:stdout] = " Usage: app12.rb [-dv] [-test level] file1 file2\n"
    ans[:stderr] = ""

    # load app with replay, but no .replay file
    assert_success(path, ans[:args]) { |out, err, status|
      assert_equal(ans[:stdout], out, "STDOUT incorrect for #{path}.")
      assert_equal(ans[:stderr], err, "STDERR incorrect for #{path}.")
    }

    assert_equal(false, File.exists?(".replay"))

    # call the app with arguments
    ans[:args]   = "filea fileb"
    ans[:stdout] = "ARGV = [\"filea\", \"fileb\"]\nrunning with args: filea, fileb\n"
    assert_success(path, ans[:args]) { |out, err, status|
      assert_equal(ans[:stdout], out, "STDOUT incorrect for #{path}.")
      assert_equal(ans[:stderr], err, "STDERR incorrect for #{path}.")
    }
    assert File.exists?(".replay")

    # run app without arguments
    ans[:args]   = "-r"
    assert_success(path, ans[:args]) { |out, err, status|
      assert_equal(ans[:stdout], out, "STDOUT incorrect for #{path}.")
      assert_equal(ans[:stderr], err, "STDERR incorrect for #{path}.")
    }

    # run app with new arguments
    ans[:args]   = "cccc dddd"
    ans[:stdout] = "ARGV = [\"cccc\", \"dddd\"]\nrunning with args: cccc, dddd\n"
    assert_success(path, ans[:args]) { |out, err, status|
      assert_equal(ans[:stdout], out, "STDOUT incorrect for #{path}.")
      assert_equal(ans[:stderr], err, "STDERR incorrect for #{path}.")
    }
    replay = File.read(".replay")
    assert_equal " cccc dddd", replay
    File.delete(".replay")
  end

  def test_app17
    path = 'ruby -I../lib data/app17.rb'
    ans = {}
    ans[:args]   = "install gem_name"
    ans[:stdout] = "Running command 'install'.\n[]"
    ans[:stderr] = ""
    assert_success(path, ans[:args]) { |out, err, status|
      assert_equal(ans[:stdout], out, "STDOUT incorrect for #{path}.")
      assert_equal(ans[:stderr], err, "STDERR incorrect for #{path}.")
    }
  end

  def test_app13
    path = 'ruby -I../lib data/app13.rb'

    ans = {}
    ans[:args]   = "--name=fred"
    ans[:stdout] = "ARGV =  [\"--name=fred\"]\nargs:   []\n--name: true\n"
    ans[:stderr] = ""
    assert_success(path, ans[:args]) { |out, err, status|
      assert_equal(ans[:stdout], out, "STDOUT incorrect for #{path}.")
      assert_equal(ans[:stderr], err, "STDERR incorrect for #{path}.")
    }
  end

  def test_app13b
    path = 'ruby -I../lib data/app13.rb'

    ans = {}
    ans[:args]   = "--name  fred"
    ans[:stdout] = "ARGV =  [\"--name\", \"fred\"]\nargs:   []\n--name: true\n"
    ans[:stderr] = ""
    assert_success(path, ans[:args]) { |out, err, status|
      assert_equal(ans[:stdout], out, "STDOUT incorrect for #{path}.")
      assert_equal(ans[:stderr], err, "STDERR incorrect for #{path}.")
    }
  end
  
  def test_app14
    path = 'ruby -I../lib data/app14.rb'

    ans = {}
    ans[:args]   = "--name  fred"
    ans[:stdout] = "ARGV =  [\"--name\", \"fred\"]\nargs:   []\n--name: fred\n"
    ans[:stderr] = ""
    assert_success(path, ans[:args]) { |out, err, status|
      assert_equal(ans[:stdout], out, "STDOUT incorrect for #{path}.")
      assert_equal(ans[:stderr], err, "STDERR incorrect for #{path}.")
    }
  end
  
  def test_app15
    path = 'ruby -rubygems -I../lib data/app15.rb'

    ans = {}
    ans[:args]   = "-h"
    ans[:stdout] = <<-EOT
NAME

    app15.rb - This is a short description

SYNOPSIS

    [-v] [--name name]

DESCRIPTION

    This is a long description with 3 paragraphs.

    The second paragraph that is long. The second paragraph that
    is long. The second paragraph that is long. The second
    paragraph that is long.

    And the third paragraph. And the third paragraph.

OPTIONS

    --version,-V
        Displays application version.

    --debug,-d
        Sets debug to true.

    --help,-h
        Displays help page.

AUTHOR  Author Name
COPYRIGHT (c) 2005
    EOT
    
    ans[:stderr] = ""
    assert_success(path, ans[:args]) { |out, err, status|
      assert_equal(ans[:stdout], out, "STDOUT incorrect for #{path}.")
      assert_equal(ans[:stderr], err, "STDERR incorrect for #{path}.")
    }
  end

  def test_app17
    path = 'ruby -I../lib data/app17.rb'

    ans = {}
    ans[:args]   = "build fred1 fred2"
    ans[:stdout] = "running\nRunning command 'build'\n@arg1: fred1\n@arg2: fred2\n"
    ans[:stderr] = ""
    assert_success(path, ans[:args]) { |out, err, status|
      assert_equal(ans[:stdout], out, "STDOUT incorrect for #{path}.")
      assert_equal(ans[:stderr], err, "STDERR incorrect for #{path}.")
    }
  end
=begin
    Usage: app17.rb [app-options] command [cmd-options] [cmd-args]

    Commands:

        build      name of gemspec file used to build the gem
        install    name of gem to install
        search     Display all gems whose name contains STRING

=end
  
  def xtest_posix
puts "*"*80
assert_equal(false, true)
    assert_equal("", "Need way to set posix mode from app!")
  end
  
end#class TestApplication
