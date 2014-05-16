class SimpleTimeSeries
  
  attr_accessor :time_vars, :data_vars

  def initialize(opts)
    @time_vars = opts[:time_vars]
    @data_vars = opts[:data_vars]
    define_data_methods_and_set_values
    define_time_methods_and_set_values
  end

  def find(what, date)
    send (what + '_on').to_sym, date
  end

  private

  def define_time_methods_and_set_values
    time_vars.each do |var, vals|
      define_getter_and_setter(var)
      instance_variable_set("@#{var}", vals) if vals
    end
  end

  def define_data_methods_and_set_values
    data_vars.each do |var, vals|
      define_getter_and_setter(var)
      var_on = "#{var}_on"
      self.class.class_eval do
        define_method(var_on) do |date|
          time_vars.each do |tv_key, tv_val|
            # tv_key is something like 'dows' or 'dates'
            # tv_val is an array of associated values
            return eval(var)[tv_val.index(date)] if tv_val.include?(date)
          end
          raise "Can't find #{var_on} for #{date}"
        end
      end
      instance_variable_set("@#{var}", vals) if vals
    end
  end

  def define_getter_and_setter(var)
    ivar = "@#{var}"
    self.class.class_eval do
      define_method(var) { instance_variable_get ivar }
      define_method "#{var}=" do |val|
        instance_variable_set ivar, val
      end
    end
  end

end
