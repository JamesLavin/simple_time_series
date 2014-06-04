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

  def current(what)
    send what.to_sym
  end

  def index_of_date_value(date)
    time_vars.each do |tv_key, tv_val|
      return tv_val.index(date) if tv_val.include?(date)
    end
    nil
  end

  def set(data_var, date, value)
    arr_index = index_of_date_value(date)
    current(data_var)[arr_index] = value
  end


  def new_time_var(var, vals)
    define_getter_and_setter(var)
    instance_variable_set("@#{var}", vals) if vals
    time_vars[var] = vals unless time_vars.has_key?(var)
  end

  def new_data_var(var, vals)
    define_getter_and_setter(var)
    var_on = "#{var}_on"
    self.class.class_eval do
      define_method("#{var}_subset") do |first, last|
        start_idx = index_of_date_value(first)
        last_idx = index_of_date_value(last)
        (start_idx && last_idx) ? eval(var)[start_idx..last_idx] : nil
      end
      define_method("#{var}_subset_set") do |first, last, val_arr|
        start_idx = index_of_date_value(first)
        last_idx = index_of_date_value(last)
        if (start_idx && last_idx)
          eval(var)[start_idx..last_idx] = val_arr
        else
          raise "Could not run #{var}_subset with values #{val_arr}"
        end
      end
      define_method("#{var}_diff") do
        eval(var).each_cons(2).map { |val1, val2| val2 - val1 }.unshift(nil)
      end
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
    data_vars[var] = vals unless data_vars.has_key?(var)
    #def eval(var).[] (first, last)
    #  send "#{var}_subset".to_sym, first, last
    #end
  end

  private

  def define_time_methods_and_set_values
    time_vars.each do |var, vals|
      new_time_var(var, vals)
    end
  end

  def define_data_methods_and_set_values
    data_vars.each do |var, vals|
      new_data_var(var, vals)
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
