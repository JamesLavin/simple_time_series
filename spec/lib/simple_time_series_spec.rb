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

  it "should be creatable" do
    @my_data.should be_a(SimpleTimeSeries)
  end

  it "should set #time_vars correctly" do
    @my_data.time_vars["dates"].should == @dates
    @my_data.time_vars["dows"].should == @dows
  end

  it "should have the correct methods" do
    [:time_vars, :time_vars=, :data_vars, :data_vars=, :find, :pizzas, :pizzas=, :pizzas_on, :miles, :miles=, :miles_on, :tasks_done, :tasks_done=, :tasks_done_on, :dows, :dows=, :dates, :dates=].each do |mthd|
      @my_data.methods.should include(mthd)
    end
  end

  it "should create accessor methods for looking up data values for any time observation" do
    @my_data.pizzas_on('Tuesday').should == 1
    @my_data.pizzas_on('Thursday').should == 0.5
    @my_data.miles_on('Sunday').should == 2.2
    @my_data.miles_on('2014-01-06').should == 12.2
    @my_data.tasks_done_on('2014-01-02').should == 3
  end

  it "should #find any data value for any time observation" do
    @my_data.find('pizzas', 'Tuesday').should == 1
    @my_data.find('pizzas', 'Thursday').should == 0.5
    @my_data.find('miles', 'Sunday').should == 2.2
    @my_data.find('miles', '2014-01-06').should == 12.2
    @my_data.find('tasks_done', '2014-01-02').should == 3
  end

  it "should create setter methods for updating a data series" do
    @my_data.pizzas_on('Tuesday').should == 1
    @my_data.pizzas = [10, 11, 12, 13, 14, 15, 16]
    @my_data.pizzas_on('Tuesday').should == 12
    @my_data.pizzas_on('Thursday').should == 14
    @my_data.pizzas_on('2014-01-04').should == 13
    @my_data.pizzas_on('2014-01-07').should == 16
  end

  describe "#current" do

    it "should print the current array for any data variable" do
      @my_data.current('pizzas').should == @pizzas
    end

  end

  describe "#index_of_date_value" do

    it "should return the array index of any date value" do
      @my_data.index_of_date_value('Thursday').should == 4
      @my_data.index_of_date_value('2014-01-01').should == 0
      @my_data.index_of_date_value('Jan 7, 2014').should == 6
    end

  end

  describe "#set" do

    it "should allow updating a single data series value" do
      @my_data.set('pizzas', 'Tuesday', 44)
      @my_data.pizzas_on('Tuesday').should == 44
      @my_data.pizzas_on('2014-01-03').should == 44
      @my_data.pizzas_on('Jan 3, 2014').should == 44
      @my_data.set('tasks_done', 'Saturday', 77)
      @my_data.tasks_done_on('Saturday').should == 77
      @my_data.tasks_done_on('2014-01-07').should == 77
      @my_data.tasks_done_on('Jan 7, 2014').should == 77
    end

    it "should allow you to build up a data series datapoint by datapoint" do
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

    it "should allow you to build up a data series datapoint by datapoint in any order" do
      @my_data.current('empty').should == []
      @my_data.set('empty', '2014-01-06', 6)
      @my_data.set('empty', 'Jan 4, 2014', 4)
      @my_data.set('empty', 'Jan 1, 2014', 1)
      @my_data.set('empty', '2014-01-03', 3)
      @my_data.set('empty', 'Thursday', 5)
      @my_data.set('empty', 'Jan 7, 2014', 7)
      @my_data.set('empty', 'Monday', 2)
      @my_data.current('empty').should == [1, 2, 3, 4, 5, 6, 7]
    end

  end

end
