# stolen directly from Open3::open3.rb!
#
# open4.rb: Spawn a program like popen, but with stderr, and pid, too. You might
# also want to use this if you want to bypass the shell. (By passing multiple
# args, which IO#popen does not allow)
#
# Usage:
#       require "open4"
#
#      stdin, stdout, stderr, pid = Open4.popen4('nroff -man')
#  or
#       include Open4
#      stdin, stdout, stderr, pid = popen4('nroff -man')

module Open4
#--{{{
  #[stdin, stdout, stderr, pid] = popen4(command);
  def popen4(*cmd)
#--{{{
    pw = IO::pipe   # pipe[0] for read, pipe[1] for write
    pr = IO::pipe
    pe = IO::pipe

    verbose = $VERBOSE
    begin
      $VERBOSE = nil # shut up warning about forking in threads, world writable
                     # dirs, etc
      cid =
        fork{
          # child
          pw[1].close
          STDIN.reopen(pw[0])
          pw[0].close

          pr[0].close
          STDOUT.reopen(pr[1])
          pr[1].close

          pe[0].close
          STDERR.reopen(pe[1])
          pe[1].close

          STDOUT.sync = true
          STDERR.sync = true

          exec(*cmd)
        }
    ensure
      $VERBOSE = verbose
    end

    pw[0].close
    pr[1].close
    pe[1].close
    pi = [pw[1], pr[0], pe[0]]
    pw[1].sync = true
    if defined? yield
      begin
        yield(cid, *pi)
        return(Process::waitpid2(cid).last)
      ensure
        pi.each{|p| p.close unless p.closed?}
      end
    end
    [cid, pw[1], pr[0], pe[0]]
#--}}}
  end
  alias open4 popen4
  module_function :popen4
  module_function :open4
#--}}}
end

if $0 == __FILE__
  status = Open4::popen4('sh'){|cid,i,o,e|i.puts 'echo 42';i.close; puts o.read;}
  p [status]
  p status.exitstatus
  p status == 0
end
