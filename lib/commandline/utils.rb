
class Module
  def param_accessor(*symbols)
    symbols.each { |sym|
      self.class_eval %{
        def #{sym}(*val)
          val.empty? ? @#{sym} : @#{sym} = val
        end
      }
    }
  end
end
