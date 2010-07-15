
require 'test/unit'
require 'test/unit/systemtest'
require 'commandline'

class TC_Application < Test::Unit::TestCase

  def setup
    # This is dumb and should be fixed
    @apps  = Dir["data/app*.rb"]
    @apps.collect! { |app| "ruby -I../lib #{app}" }

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
  ANS[:app10][:args]   = ""
  ANS[:app10][:stdout] = "Placeholder for cvs like command test\n"
  ANS[:app10][:stderr] = ""
#--------------------------------------------------------------
#--------------------------------------------------------------
  ANS[:app11][:args]   = ""
  ANS[:app11][:stdout] = " Usage: app11.rb \n"
  ANS[:app11][:stderr] = ""
#--------------------------------------------------------------
  def teardown
  end

  def test_apps
    @apps.each { |path|
      app = File.basename(path, ".rb").to_sym
      assert_success(path, ANS[app][:args]) { |out, err, status|
        assert_equal(ANS[app][:stdout], out, "STDOUT incorrect for #{path}.")
        assert_equal(ANS[app][:stderr], err, "STDERR incorrect for #{path}.")
      }
    }
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

  def test_app9
    require 'data/app9'
    app = nil
    assert_nothing_raised { app = App.run(%w{filea fileb}) }
    od = app.instance_variable_get("@option_data")
    assert_equal("filea", app.instance_variable_get("@file1"))
    assert_equal("fileb", app.instance_variable_get("@file2"))
    assert_equal([:file1, :file2], app.instance_variable_get("@arg_names"))
  end

  def test_replay
    path = 'data/app12.rb'
    ans = {}
    ans[:args]   = ""
    ans[:stdout] = " Usage: [-dv] [-test] file1 file2 \n"
    ans[:stderr] = ""

    # load app with replay, but no .replay file
    assert_success(path, ans[:args]) { |out, err, status|
      assert_equal(ANS[:stdout], out, "STDOUT incorrect for #{path}.")
      assert_equal(ANS[:stderr], err, "STDERR incorrect for #{path}.")
    }

    # call the app with arguments
    ans[:args]   = "filea fileb"
    ans[:stdout] = "running with args: file1 fileb"
    assert_success(path, ans[:args]) { |out, err, status|
      assert_equal(ANS[:stdout], out, "STDOUT incorrect for #{path}.")
      assert_equal(ANS[:stderr], err, "STDERR incorrect for #{path}.")
    }
    assert File.exists?(".replay")

    # run app without arguments
    ans[:args]   = ""
    assert_success(path, ans[:args]) { |out, err, status|
      assert_equal(ANS[:stdout], out, "STDOUT incorrect for #{path}.")
      assert_equal(ANS[:stderr], err, "STDERR incorrect for #{path}.")
    }

    # run app with new arguments
    ans[:args]   = "cccc dddd"
    ans[:stdout] = "running with args: cccc dddd"
    assert_success(path, ans[:args]) { |out, err, status|
      assert_equal(ANS[:stdout], out, "STDOUT incorrect for #{path}.")
      assert_equal(ANS[:stderr], err, "STDERR incorrect for #{path}.")
    }
    replay = File.read(".replay")
    assert_equal "blah blah", replay
    File.delete(".replay")
  end

  def test_posix
    assert_equal("", "Need way to set posix mode from app!")
  end
end#class TC_Application
