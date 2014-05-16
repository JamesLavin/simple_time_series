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
      ivar = "@#{var}"
      self.class.class_eval do
        define_method(var) { instance_variable_get ivar }
        define_method "#{var}=" do |val|
          instance_variable_set ivar, val
        end
      end
      instance_variable_set(ivar, vals) if vals
    end
  end

  def define_data_methods_and_set_values
    data_vars.each do |var, vals|
      ivar = "@#{var}"
      var_on = "#{var}_on"
      self.class.class_eval do
        define_method(var) { instance_variable_get ivar }
        define_method "#{var}=" do |val|
          instance_variable_set ivar, val
        end
        define_method(var_on) do |date|
          if dates && dates.include?(date)
            eval(var)[date_to_i(date)]
          elsif dows && dows.include?(date)
            eval(var)[dows_to_i(date)]
          else
            raise "Can't find #{var_on} for #{date}"
          end
        end
      end
      instance_variable_set(ivar, vals) if vals
    end
  end

  def define_getter_and_setter(var)

  end

  def dows_to_i(date)
    dows.index(date)
  end

  def date_to_i(date)
    dates.index(date)
  end

end
