require 'spec_helper'

describe SimpleTimeSeries do

  before do
    @dows = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    @dates = ['2014-01-01', '2014-01-02', '2014-01-03', '2014-01-04', '2014-01-05', '2014-01-06', '2014-01-07']
    @full_dates = ['Jan 1, 2014', 'Jan 2, 2014', 'Jan 3, 2014', 'Jan 4, 2014', 'Jan 5, 2014', 'Jan 6, 2014', 'Jan 7, 2014']
    @pizzas = [0, 0, 1, 0, 0.5, 0, 2]
    @miles = [2.2, 3.1, 0.0, 4.3, 1.2, 12.2, 2.3]
    @tasks_done = [2, 3, 0, 14, 3, 11, 0]
    @my_data = SimpleTimeSeries.new(:data_vars =>
                                       {'pizzas' => @pizzas, 'miles' => @miles,
                                        'tasks_done' => @tasks_done, 'empty' => []},
                                    :time_vars =>
                                       {'dows' => @dows, 'dates' => @dates,
                                        'full_dates' => @full_dates})
  end

  it "is creatable" do
    @my_data.should be_a(SimpleTimeSeries)
  end

  it "sets #time_vars correctly" do
    @my_data.time_vars["dates"].should == @dates
    @my_data.time_vars["dows"].should == @dows
  end

  it "creates the correct methods" do
    [:time_vars, :time_vars=, :data_vars, :data_vars=, :find, :pizzas, :pizzas=, :pizzas_on, :miles, :miles=, :miles_on, :tasks_done, :tasks_done=, :tasks_done_on, :dows, :dows=, :dates, :dates=].each do |mthd|
      @my_data.methods.should include(mthd)
    end
  end

  it "creates accessor methods for looking up data values for any time observation" do
    @my_data.pizzas_on('Tuesday').should == 1
    @my_data.pizzas_on('Thursday').should == 0.5
    @my_data.miles_on('Sunday').should == 2.2
    @my_data.miles_on('2014-01-06').should == 12.2
    @my_data.tasks_done_on('2014-01-02').should == 3
  end

  it "creates a #find method for finding any data value for any time observation" do
    @my_data.find('pizzas', 'Tuesday').should == 1
    @my_data.find('pizzas', 'Thursday').should == 0.5
    @my_data.find('miles', 'Sunday').should == 2.2
    @my_data.find('miles', '2014-01-06').should == 12.2
    @my_data.find('tasks_done', '2014-01-02').should == 3
  end

  it "creates a #find method for finding any data values for a range of observations" do
    @my_data.find('pizzas', 'Tuesday', 'Thursday').should == [1, 0, 0.5]
    @my_data.find('pizzas', 'Thursday', '2014-01-07').should == [0.5, 0, 2]
    @my_data.find('miles', 'Saturday', '2014-01-07').should == 2.3
    @my_data.find('miles', 'Sunday', '2014-01-07').should == [2.2, 3.1, 0.0, 4.3, 1.2, 12.2, 2.3]
    @my_data.find('miles', 'Jan 2, 2014','2014-01-06').should == [3.1, 0.0, 4.3, 1.2, 12.2]
    @my_data.find('tasks_done', '2014-01-02', 'Friday').should == [3, 0, 14, 3, 11]
  end

  #it "creates a #find_plus_label method for finding any data value for any time observation" do
  #  @my_data.find('pizzas', 'Tuesday').should == 1
  #  @my_data.find('pizzas', 'Thursday').should == 0.5
  #  @my_data.find('miles', 'Sunday').should == 2.2
  #  @my_data.find('miles', '2014-01-06').should == 12.2
  #  @my_data.find('tasks_done', '2014-01-02').should == 3
  #end

  it "creates a #find_plus_label method for finding any data values for a range of observations" do
    @my_data.find_plus_label('pizzas', 'Tuesday', 'Thursday').should == ['pizzas', 1, 0, 0.5]
    @my_data.find_plus_label('pizzas', 'Thursday', '2014-01-07').should == ['pizzas', 0.5, 0, 2]
    #@my_data.find_plus_label('miles', 'Saturday', '2014-01-07').should == 2.3
    @my_data.find_plus_label('miles', 'Sunday', '2014-01-07').should == ['miles', 2.2, 3.1, 0.0, 4.3, 1.2, 12.2, 2.3]
    @my_data.find_plus_label('miles', 'Jan 2, 2014','2014-01-06').should == ['miles', 3.1, 0.0, 4.3, 1.2, 12.2]
    @my_data.find_plus_label('tasks_done', '2014-01-02', 'Friday').should == ['tasks_done', 3, 0, 14, 3, 11]
  end

  it "creates setter methods for updating a data series" do
    @my_data.pizzas_on('Tuesday').should == 1
    @my_data.pizzas = [10, 11, 12, 13, 14, 15, 16]
    @my_data.pizzas_on('Tuesday').should == 12
    @my_data.pizzas_on('Thursday').should == 14
    @my_data.pizzas_on('2014-01-04').should == 13
    @my_data.pizzas_on('2014-01-07').should == 16
  end

  describe "#current" do

    it "prints the current array for any data variable" do
      @my_data.current('pizzas').should == @pizzas
    end

  end

  describe "#index_of_date_value" do

    it "returns the array index of any date value" do
      @my_data.index_of_date_value('Thursday').should == 4
      @my_data.index_of_date_value('2014-01-01').should == 0
      @my_data.index_of_date_value('Jan 7, 2014').should == 6
    end

  end

  describe "#set" do

    it "updates a single data series value" do
      @my_data.set('pizzas', 'Tuesday', 44)
      @my_data.pizzas_on('Tuesday').should == 44
      @my_data.pizzas_on('2014-01-03').should == 44
      @my_data.pizzas_on('Jan 3, 2014').should == 44
      @my_data.set('tasks_done', 'Saturday', 77)
      @my_data.tasks_done_on('Saturday').should == 77
      @my_data.tasks_done_on('2014-01-07').should == 77
      @my_data.tasks_done_on('Jan 7, 2014').should == 77
    end

    it "lets you build up a data series datapoint by datapoint" do
      @my_data.current('empty').should == []
      @my_data.set('empty', 'Jan 1, 2014', 1)
      @my_data.set('empty', 'Monday', 2)
      @my_data.set('empty', '2014-01-03', 3)
      @my_data.set('empty', 'Jan 4, 2014', 4)
      @my_data.set('empty', 'Thursday', 5)
      @my_data.set('empty', '2014-01-06', 6)
      @my_data.set('empty', 'Jan 7, 2014', 7)
      @my_data.current('empty').should == [1, 2, 3, 4, 5, 6, 7]
    end

    it "lets you build up a data series datapoint by datapoint in any order" do
      @my_data.current('empty').should == []
      @my_data.set('empty', '2014-01-06', 6)
      @my_data.set('empty', 'Jan 4, 2014', 4)
      @my_data.set('empty', 'Jan 1, 2014', 1)
      @my_data.set('empty', '2014-01-03', 3)
      @my_data.set('empty', 'Thursday', 5)
      @my_data.set('empty', 'Jan 7, 2014', 7)
      @my_data.set('empty', 'Monday', 2)
      @my_data.current('empty').should == [1, 2, 3, 4, 5, 6, 7]
      @my_data.empty.should == [1, 2, 3, 4, 5, 6, 7]
    end

  end

  describe "#new_time_var" do

    it "lets you create a new time variable after object instantiation" do
      @my_data.new_time_var('short_dow',['Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat'])
      @my_data.tasks_done_on('Fri').should == 11
      @my_data.pizzas_on('Thurs').should == 0.5
    end

  end

  describe "#new_data_var" do

    it "lets you create a new data variable after object instantiation" do
      @my_data.new_data_var('hours_of_tv',[7, 3, 3.5, 3, 4, 6.5, 11])
      @my_data.hours_of_tv.should == [7, 3, 3.5, 3, 4, 6.5, 11]
      @my_data.hours_of_tv_on('Friday').should == 6.5
      @my_data.hours_of_tv_on('2014-01-01').should == 7
    end

    it "lets you use a new data variable with a new time variable" do
      @my_data.new_time_var('short_dow',['Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat'])
      @my_data.new_data_var('hours_of_tv',[7, 3, 3.5, 3, 4, 6.5, 11])
      @my_data.hours_of_tv_on('Fri').should == 6.5
      @my_data.hours_of_tv_on('Sun').should == 7
    end

  end

  describe "#[,]" do

    it "returns the correct array subset when passed index values" do
      @my_data.pizzas[1,4].should == @pizzas[1,4]
    end

    #it "returns the correct array subset when passed index values" do
    #  @my_data.miles['2014-01-03','Saturday'].should = [0.0, 4.3, 1.2, 12.2, 2.3]
    #end

  end

  describe "#xyz_subset" do

    it "returns the correct array subset when passed time_var values" do
      @my_data.pizzas_subset('Tuesday','Thursday').should == [1, 0, 0.5]
    end

    it "returns the correct array subset when passed a single time_var value" do
      @my_data.pizzas_subset('Thursday').should == [0.5]
    end

    it "returns the correct array subset when passed time_var values" do
      @my_data.pizzas_subset('Tuesday','Saturday').should == [1, 0, 0.5, 0, 2]
    end

    it "returns the correct array subset when passed time_var values" do
      @my_data.pizzas_subset('2014-01-03','2014-01-07').should == [1, 0, 0.5, 0, 2]
    end

    it "returns the correct array subset when passed time_var values" do
      @my_data.tasks_done_subset('Jan 2, 2014','Jan 5, 2014').should == [3, 0, 14, 3]
      @my_data.pizzas_subset('Jan 1, 2014','Jan 4, 2014').should == [0, 0, 1, 0]
    end

    it "returns the correct array subset when passed a mix of time_var types" do
      @my_data.tasks_done_subset('Monday','Jan 5, 2014').should == [3, 0, 14, 3]
      @my_data.pizzas_subset('Jan 1, 2014','2014-01-04').should == [0, 0, 1, 0]
    end

  end

  describe "#xyz_subset_set" do

    it "returns the correct array subset when passed time_var values" do
      @my_data.pizzas_subset('Tuesday','Thursday').should == [1, 0, 0.5]
      @my_data.pizzas_subset_set('Tuesday','Thursday', [7, 8, 9.5])
      @my_data.pizzas_subset('Tuesday','Thursday').should == [7, 8, 9.5]
      @my_data.pizzas_subset('2014-01-03','Jan 5, 2014').should == [7, 8, 9.5]
      @my_data.pizzas.should == [0, 0, 7, 8, 9.5, 0, 2]
    end

  end

  describe "#xyz_diff" do

    it "should calculate the correct vector of differences for the referenced data_var" do
      @my_data.tasks_done_diff.should == [nil, 1, -3, 14, -11, 8, -11]
      @my_data.tasks_done_diff[3].should == 14
      @my_data.tasks_done_diff[3, 2].should == [14, -11]
      @my_data.tasks_done_diff[3, 4].should == [14, -11, 8, -11]
      @my_data.pizzas_diff.should == [nil, 0, 1, -1, 0.5, -0.5, 2]
    end

    it "should let me access a single value in a vector of differences with any time_var value" do
      @my_data.tasks_done_diff('Saturday').should == -11
      @my_data.tasks_done_diff('Sunday').should be_nil
      @my_data.pizzas_diff('Saturday').should == 2
      @my_data.pizzas_diff('2014-01-01').should be_nil
      @my_data.pizzas_diff('Jan 4, 2014').should == -1
    end

    it "should let me access a subarray of a vector of differences with any time_var value" do
      @my_data.tasks_done_diff('Sunday','Monday').should == [nil, 1]
      @my_data.tasks_done_diff('Tuesday','Saturday').should == [-3, 14, -11, 8, -11]
    end

  end

  describe "#xyz_cumsum" do

    it "calculates the correct vector of cumulative sums for the referenced data_var" do
      # @tasks_done = [2, 3, 0, 14, 3, 11, 0]
      @my_data.tasks_done_cumsum.should == [2, 5, 5, 19, 22, 33, 33]
      @my_data.tasks_done_cumsum[3].should == 19
      @my_data.tasks_done_cumsum[3, 2].should == [19, 22]
      @my_data.tasks_done_cumsum[3, 4].should == [19, 22, 33, 33]
      @my_data.pizzas_cumsum.should == [0, 0, 1, 1, 1.5, 1.5, 3.5]
    end

    it "accesses a single value in a vector of cumulative sums with any time_var value" do
      @my_data.tasks_done_cumsum('Saturday').should == 33
      @my_data.tasks_done_cumsum('Sunday').should == 2
      @my_data.pizzas_cumsum('Saturday').should == 3.5
      @my_data.pizzas_cumsum('2014-01-01').should == 0
      @my_data.pizzas_cumsum('Jan 4, 2014').should == 1
    end

    it "accesses a subarray of a vector of differences with any time_var value" do
      @my_data.tasks_done_cumsum('Sunday','Monday').should == [2, 5]
      @my_data.tasks_done_cumsum('Tuesday','Saturday').should == [5, 19, 22, 33, 33]
    end

  end

  describe "#data_array" do

    it "builds an array of specified arrays" do
      @my_data.data_array('tasks_done', {}).should == [ @my_data.current('tasks_done') ]
      @my_data.data_array('tasks_done', {}).should == [ [2, 3, 0, 14, 3, 11, 0] ]
      @my_data.data_array('dates', 'tasks_done', 'pizzas', {}).
               should == [ @my_data.current('dates'),
                           @my_data.current('tasks_done'),
                           @my_data.current('pizzas') ]
      @my_data.data_array('tasks_done', 'pizzas', {:start => 'Tuesday', :end => 'Thursday'}).
               should == [ @my_data.find('tasks_done','Tuesday','Thursday'),
                           @my_data.find('pizzas', '2014-01-03', 'Jan 5, 2014') ]
    end

    it "builds an array of specified arrays with variable names prepended to each array" do
      @my_data.data_array('tasks_done', {:prepend_names => true}).
               should == [ ['tasks_done', 2, 3, 0, 14, 3, 11, 0] ]
      @my_data.data_array('miles', 'tasks_done', {:prepend_names => true}).
               should == [ ['miles', 2.2, 3.1, 0.0, 4.3, 1.2, 12.2, 2.3],
                           ['tasks_done', 2, 3, 0, 14, 3, 11, 0] ]
      @my_data.data_array('dates', 'tasks_done', 'pizzas', {:prepend_names => true}).
               should == [ ['dates', '2014-01-01', '2014-01-02', '2014-01-03', '2014-01-04', '2014-01-05', '2014-01-06', '2014-01-07'],
                           ['tasks_done', 2, 3, 0, 14, 3, 11, 0],
                           ['pizzas', 0, 0, 1, 0, 0.5, 0, 2] ]
    end

    it "builds an array of specified arrays subsetted correctly with variable names prepended to each array" do
      @my_data.data_array('tasks_done', 'pizzas', {:start => 'Monday', :end => 'Friday',
                                                   :prepend_names => true}).
               should == [ ['tasks_done', 3, 0, 14, 3, 11],
                           ['pizzas', 0, 1, 0, 0.5, 0] ]
      @my_data.data_array('dates', 'tasks_done', 'pizzas', {:prepend_names => true,
                                                            :start => '2014-01-02',
                                                            :end => 'Saturday'}).
               should == [ ['dates', '2014-01-02', '2014-01-03', '2014-01-04', '2014-01-05', '2014-01-06', '2014-01-07'],
                           ['tasks_done', 3, 0, 14, 3, 11, 0],
                           ['pizzas', 0, 1, 0, 0.5, 0, 2] ]
    end

    #it "builds an array of specified arrays with variable names prepended to each array" do
    #  @my_data.data_array('tasks_done', {}).should == [ @my_data.current('tasks_done') ]
    #  @my_data.data_array('tasks_done', 'pizzas', {:prepend_names => true}).should == [ @my_data.current('tasks_done'),
    #                                                              @my_data.current('pizzas') ]
    #  @my_data.data_array('tasks_done', 'pizzas', {:start => 'Tuesday', :end => 'Thursday'}).
    #          should == [ @my_data.find('tasks_done','Tuesday','Thursday'),
    #                      @my_data.find('pizzas', '2014-01-03', 'Jan 5, 2014') ]
    #end

  end

end
