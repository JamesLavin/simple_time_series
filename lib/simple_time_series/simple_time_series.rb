class SimpleTimeSeries
  
  attr_accessor :time_vars, :data_vars

  def initialize(opts)
    @time_vars = opts[:time_vars]
    @data_vars = opts[:data_vars]
    define_data_methods_and_set_values
    define_time_methods_and_set_values
  end

  def find(what, date, end_date=nil)
    if end_date
      send (what + '_on').to_sym, date, end_date
    else
      send (what + '_on').to_sym, date
    end
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
      define_method("#{var}_subset") do |first, last=first|
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
      define_method("#{var}_diff") do |first=nil, last=nil| # should work only on numeric data
        # this could be made more efficient by caching the full array and/or calculating only a subset of values
        time_vars.each do |tv_key, tv_val|
          start_idx = index_of_date_value(first) || 0
          last_idx = index_of_date_value(last) || (first.nil? ? -1 : start_idx)
          answer = (eval(var).each_cons(2).map { |val1, val2| val2 - val1 }.unshift(nil))[start_idx..last_idx]
          return answer.length == 1 ? answer[0] : answer
        end
      end
      # should DRY out variable creation, probably by passing in a strategy along with the variable name
      define_method("#{var}_cumsum") do |first=nil, last=nil| # should work only on numeric data
        # this could be made more efficient by caching the full array and/or calculating only a subset of values
        time_vars.each do |tv_key, tv_val|
          start_idx = index_of_date_value(first) || 0
          last_idx = index_of_date_value(last) || (first.nil? ? -1 : start_idx)
          sum = eval(var)[0]
          answer = (eval(var).each_cons(2).map { |val1, val2| sum += val2 }.unshift(eval(var)[start_idx]))[start_idx..last_idx]
          return answer.length == 1 ? answer[0] : answer
        end
      end
      define_method(var_on) do |first, last=nil|
        time_vars.each do |tv_key, tv_val|
          # tv_key is something like 'dows' or 'dates'
          # tv_val is an array of associated values
          start_idx = index_of_date_value(first) || 0
          last_idx = index_of_date_value(last) || (first.nil? ? -1 : start_idx)
          if start_idx != last_idx #&& tv_val.include?(last)
            return eval(var)[start_idx..last_idx]
          elsif tv_val.include?(first)
            return eval(var)[start_idx]
          end
        end
        raise "Can't find #{var_on} for #{first}"
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
