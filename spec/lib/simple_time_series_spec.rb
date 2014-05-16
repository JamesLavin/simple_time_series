require 'spec_helper'

describe SimpleTimeSeries do

  before do
    @dows = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    @dates = ['2014-01-01', '2014-01-02', '2014-01-03', '2014-01-04', '2014-01-05', '2014-01-06', '2014-01-07']
    @pizzas = [0, 0, 1, 0, 0.5, 0, 2]
    @miles = [2.2, 3.1, 0.0, 4.3, 1.2, 12.2, 2.3]
    @tasks_done = [2, 3, 0, 14, 3, 11, 0]

  end

  it "should be creatable" do
    my_data = SimpleTimeSeries.new(variables = {'dows' => @dows, 'dates' => @dates,
                                                'pizzas' => @pizzas, 'miles' => @miles,
                                                'tasks_done' => @tasks_done})
    my_data.should be_a(SimpleTimeSeries)
  end

end
