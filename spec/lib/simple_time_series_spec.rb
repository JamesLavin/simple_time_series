require 'spec_helper'

describe SimpleTimeSeries do

  before do
    @dows = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    @dates = ['2014-01-01', '2014-01-02', '2014-01-03', '2014-01-04', '2014-01-05', '2014-01-06', '2014-01-07']
    @pizzas = [0, 0, 1, 0, 0.5, 0, 2]
    @miles = [2.2, 3.1, 0.0, 4.3, 1.2, 12.2, 2.3]
    @tasks_done = [2, 3, 0, 14, 3, 11, 0]
    @my_data = SimpleTimeSeries.new(variables = {'dows' => @dows, 'dates' => @dates,
                                                 'pizzas' => @pizzas, 'miles' => @miles,
                                                 'tasks_done' => @tasks_done})
  end

  it "should be creatable" do
    @my_data.should be_a(SimpleTimeSeries)
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
    @my_data.pizzas = [10, 11, 12, 13, 14, 15, 16]
    @my_data.pizzas_on('Tuesday').should == 12
    @my_data.pizzas_on('Thursday').should == 14
    @my_data.pizzas_on('2014-01-04').should == 13
    @my_data.pizzas_on('2014-01-07').should == 16
  end

end
