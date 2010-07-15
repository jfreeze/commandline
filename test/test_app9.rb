
require 'test/unit'
require 'test/unit/systemtest'
require 'commandline'

class TC_App9 < Test::Unit::TestCase

  def test_app9
    load 'data/app9.rb'
    app = nil
    assert_nothing_raised { app = App.run(%w{filea fileb}) }
    od = app.instance_variable_get("@option_data")
    assert_equal("filea", app.instance_variable_get("@file1"))
    assert_equal("fileb", app.instance_variable_get("@file2"))
    assert_equal([:file1, :file2], app.instance_variable_get("@arg_names"))
  end

end#TC_App9
