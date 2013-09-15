module TraceVisualization
  def self.assert_instance_of(object, expected_class)
    raise "Illegal parameter type: expected #{expected_class}, actual #{object.class}. Object: #{object}" if not object.instance_of? expected_class
  end
end