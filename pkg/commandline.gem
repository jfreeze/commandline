require 'rubygems'

SPEC = Gem::Specification.new do |s|
  s.name     = "commandline"
  s.version  = "0.7.12"
  s.author   = "Jim Freeze"
  s.email    = "commandline@freeze.org"
  s.homepage = "http://rubyforge.org/projects/optionparser/"
  s.platform = Gem::Platform::RUBY
  s.summary  = "Tools to facilitate creation of command line "+
               "applications and flexible parsing of command line "+
               "options."
  #candidates = Dir.glob("{bin,docs,lib,test}/**/*")
  candidates = Dir.glob("{bin,docs,lib}/**/*")
  candidates << "CHANGELOG"
  s.files    = candidates.delete_if do |item|
                 item.include?("CVS") || item.include?("rdoc")
               end
  s.require_path = "lib"
  s.autorequire  = "commandline"
  #s.test_files   = ["test/testall.rb", "test/tc_option.rb"]
  s.has_rdoc     = true
  s.extra_rdoc_files = ["README", "LICENSE", "CHANGELOG", "TODO"]
  s.add_dependency("text-format", "= 1.0.0")
end
