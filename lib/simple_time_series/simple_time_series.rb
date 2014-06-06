class SimpleTimeSeries
  
  DEBUG = false

  attr_accessor :time_vars, :data_vars

  def initialize(opts)
    @time_vars = opts[:time_vars]
    @data_vars = opts[:data_vars]
    define_data_methods_and_set_values
    define_time_methods_and_set_values
  end

  def find(what, date, end_date=nil, opts={})
    puts "Calling send(#{what}_on, #{date}, #{end_date}, #{opts})" if DEBUG
    send((what + '_on').to_sym, date, end_date, opts)
  end

  def find_plus_label(what, date, end_date=nil)
    find(what, date, end_date).dup.unshift(what)
  end

  def sum_by_date(*data_var_names, opts)
    arr = []
    data_var_names.each do |name|
      if opts[:start] && opts[:end]
        arr << find(name, opts[:start], opts[:end], opts)
      else
        arr << current(name, opts)
      end
    end
    arr = arr.transpose.map { |arr| arr.reduce(:+) }
    opts[:prepend_name] ? arr.unshift(opts[:prepend_name]) : arr
  end

  def data_array(*data_var_names, opts)
    err_msg = "The last parameter passed to #data_array must be a hash of start/end values.\n"
    err_msg += "Example: {:start => 'Tuesday', :end => '2014-01-06'}\n"
    err_msg += "If you want to use all observations, you can pass a blank hash, like {}\n"
    raise err_msg unless opts
    data_arr = []
    Array(data_var_names).each do |name|
      puts "Looping through data_var_names inside data_array with #{name}" if DEBUG
      if opts[:start] && opts[:end]
        puts "Calling find(#{name}, #{opts[:start]}, #{opts[:end]}, #{opts})" if DEBUG
        data_arr << find(name, opts[:start], opts[:end], opts)
      else
        data_arr << current(name, opts)
      end
    end
    data_arr
  end

  def current(what, opts={})
    puts "#current called with #{what} and #{opts}" if DEBUG
    vals = send(what.to_sym, opts)
    opts[:prepend_names] ? vals.dup.unshift(what) : vals
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
    define_var_on(var)
  end

  def new_data_var(var, vals)
    define_getter_and_setter(var)
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
          answer = (eval(var).each_cons(2).map { |val1, val2| val2 - val1 }.dup.unshift(nil))[start_idx..last_idx]
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
          answer = (eval(var).each_cons(2).map { |val1, val2| sum += val2 }.dup.unshift(eval(var)[start_idx]))[start_idx..last_idx]
          return answer.length == 1 ? answer[0] : answer
        end
      end
    end
    define_var_on(var)
    instance_variable_set("@#{var}", vals) if vals
    data_vars[var] = vals unless data_vars.has_key?(var)
  end

  private

  def define_var_on(var)
    self.class.class_eval do
      define_method("#{var}_on") do |first, last=nil, opts={}|
        time_vars.each do |tv_key, tv_val|
          # tv_key is something like 'dows' or 'dates'
          # tv_val is an array of associated values
          start_idx = index_of_date_value(first) || 0
          last_idx = index_of_date_value(last) || (first.nil? ? -1 : start_idx)
          puts "Called with #{first}, #{last}, #{opts}" if DEBUG
          puts "start_idx = #{start_idx}; last_idx = #{last_idx}" if DEBUG
          if start_idx != last_idx
            arr = eval(var)[start_idx..last_idx]
            return (opts[:prepend_names] ? arr.dup.unshift(var) : arr)
          elsif start_idx
            return eval(var)[start_idx]
          else
            raise "Can't find #{var}_on for #{first}"
          end
        end
      end
    end
  end

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
      define_method(var) do |opts={}|
        instance_variable_get ivar
      end
      define_method "#{var}=" do |val|
        instance_variable_set ivar, val
      end
    end
  end

end
