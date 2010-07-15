
module Test

module Unit

  class TestCase
    require 'open4'
    require 'timeout'
    def run_app(app, *args)
      cmd = [app, args].flatten.join(" ")
      out = nil
      err = nil
      Timeout::timeout(5) {
        status = Open4.popen4(cmd) { |cid, stdin, stdout, stderr|
          out = stdout.read
          err = stderr.read
          stdin.close_write
        }
      }
    rescue(Timeout::Error) => err
      puts "ERROR running #{app} #{args}"
      puts err
      puts err.backtrace
      [out, err, status]
    end


    # the above is having problems. I don't know why
    def run_app(app, *args)
      cmd = "#{app} #{args.join(" ")}"
      puts "==> Command: #{cmd}" if $DEBUG
      out = `#{cmd} 2> __stderr.txt`
      status = $?
      err = File.read("__stderr.txt")
      File.delete("__stderr.txt")
      [out, err, status]
    end
    
    def assert_success(app, *args)
      args.compact!
      out, err, status = run_app(app, args)
      assert_equal(true, status.success?, 
        "Failure running #{[app,args].delete_if { |i| i.empty? }.join(" ")} "+
        "with error(s):\n => stderr: '#{err}'\n => stdout: '#{out}'.")
      yield(out, err, status) if block_given?
    end

    def assert_failure(app, *args)
      out, err, status = run_app(app, args)
      assert_equal(false, status.success?,
        "No failure running #{[app,args].delete_if { |i| i.empty? }.join(" ")}.")
      yield(out, err, status) if block_given?
    end

    def assert_coredump(app, *args)
      out, err, status = run_app(app, args)
      assert_equal(true, status.coredump?,
        "Running #{[app,args].delete_if { |i| i.empty? }.join(" ")} did not coredump.")
      yield(out, err, status) if block_given?
    end
    def assert_no_coredump(app, *args)
      out, err, status = run_app(app, args)
      assert_equal(false, status.coredump?,
        "Running #{[app,args].delete_if { |i| i.empty? }.join(" ")} caused coredump.")
      yield(out, err, status) if block_given?
    end

    def assert_stopped(app, *args)
      out, err, status = run_app(app, args)
      assert_equal(true, status.stopped?,
        "Running #{[app,args].delete_if { |i| i.empty? }.join(" ")} not stopped.")
      yield(out, err, status) if block_given?
    end

  end
end#module Unit
end#module Test
