# This file contains additions to the Kernel module.
# Essentially, any functions that need global access go here.

module Kernel
  
  # This is a simple debug that takes either a description and an argument
  # or just an argument.
  # We may want to add more debug statements, maybe some that use pp or inspect.
  def debug(desc, *arg)
    return unless $DEBUG
    if arg.empty?
      puts "==>  #{desc}" 
    else
      puts "==>  #{desc}: #{arg.join(", ")}"
    end
  end
end