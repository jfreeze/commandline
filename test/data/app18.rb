require 'rubygems'
require 'commandline'
require 'pp'


class App < CommandLine::Application
  def initialize
    author "Firstname Lastname"
    synopsis "[-dvh] command [command-options] [command-args]"
    short_description "Test for cvs like commands"
    options :debug, :version, :help
    
    option :names => "-f", :arity => [2,3]

    define_commands
  end

  def define_commands
    define_edit_command
    define_history_command
  end
  
  def define_edit_command
    command :name => "edit",
            :synopsis => "[-lRa] [files...]",
            :cmd_description => "Get ready to edit a watched file" do
      option :flag, :names => "-l",
             :opt_description => "Local directory only, not recursive"
      option :flag, :names => "-R",
             :opt_description => "Process directories recursively"
      option :flag, :names => "-a",
             :opt_description => "Specify what actions for temporary watch, one of "+
                                 "edit,unedit,commit,all,none"
      expected_args [1,-1]
    end
  end
  
  def define_history_command
    command :name => "history",
            :use_method => "do_history",
            :synopsis => "[-aclowT] [-D date] [-b str] file [file2...]",
            :cmd_description => "Returns history of filename" do
      option :flag, :names => "-T",
             :opt_description => "Produce report on all TAGs"
      option :flag, :names => "-c",
             :opt_description => "Committed (Modified) file"
      option :flag, :names => "-o",
             :opt_description => "Checked out modules"
      option :flag, :names => "-a",
             :opt_description => "All users (Default is self)"
      option :flag, :names => "-l",
             :opt_description => "Last modified (committed or modified report)"
      option :flag, :names => "-w",
             :opt_description => "Working directory must match"
      option :names => "-D",
             :opt_description => "Since Date (many formats)",
             :arg_description => "<date>",
             :opt_found => get_arg, :opt_not_found => lambda { Time.now }
      option :names => "-b",
             :opt_description => "Back to record with str in module/file/repos field",
             :arg_description => "<str>",
             :opt_found => get_arg
      # You get the idea
      expected_args [1,-1]  # files
    end
  end

  def main
    # opt now points to the application options
    # the developer is responsible for setting any any app persistant
    # data that is in option_data
    puts "App #{name} was called with options "
    pp opt.to_h
    puts "and args"
    pp args
 
 pp @command_hash.keys
 pp @command_hash["edit"]
 # commands at this pt don't have an optionparser
 # OptionParser.new(@commands["edit"].options).parse(args)
  end

  def edit
    # opt now points to the option data for edit
    # the remaining argv is parsed with the edit option list
    puts "the 'edit' command was called with options "
    pp opt
    puts "and args "
    pp args
  end
  
  def do_history
    puts "the 'history' command was called with options "
    pp opt
    puts " and args "
    pp args
  end

end#class App

=begin
cmds = %w{edit history}
app_opt = Option.new(:names => %w(-d))
cmd_edit_opt    = Option.new(
                    :names => "-r", 
                    :arg_description => "")

cmd_history_opt = Option.new(:flag, :names => %w(--verbose -v))

commands = {
  "edit"    => OptionParser.new(cmd_edit_opt),
  "history" => OptionParser.new(cmd_history_opt)
}
=end
=begin
  Silly scenarios to think about
  
  app command -- frozen options
  
  In this case, [-- frozen options] is sent to command's optionparser.
  
  app -- command 
  This would be an error, since ther is no command
=end