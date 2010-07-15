require 'rubygems'
require 'text/format'

f = Text::Format.new
f.columns = 30
f.first_indent  = 8
f.body_indent   = 4
#f.tag_paragraph = true
#f.extra_space = true

text1 = "this is a test **"*5
text2 = "abcd efgh ijklm ** "*5
pars = [text1, text2]
f.tag_paragraph = false
f1 = f.paragraphs(pars)
#f1 = f.paragraphs(text1)

puts; puts

f.tag_paragraph = true
#f.extra_space = true
f2 = f.paragraphs(pars)
puts f1
puts f2

