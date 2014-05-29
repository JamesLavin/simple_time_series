# SimpleTimeSeries

Packages a set of time series variables into an object that allows easy data access and manipulation

## Installation

Add this line to your application's Gemfile:

    gem 'simple_time_series'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_time_series

## Usage

Example:

Imagine you have recorded over the past week the number of pizzas you have consumed, the number of miles you've run, and the number of tasks you've done and you have stored these values in simple Ruby arrays (that you can name anything you want):

    pizzas = [0, 0, 1, 0, 0.5, 0, 2]
    miles = [2.2, 3.1, 0.0, 4.3, 1.2, 12.2, 2.3]
    tasks_done = [2, 3, 0, 14, 3, 11, 0]

To associate these observations with the days they belong to, you create one or more ordered arrays holding sequential observation numbers, days-of-the-week, dates or anything else you want to use to label the ordered events/dates for which you're recording data. (You can put whatever time/date values in these arrays that you wish. Only their order in the array(s) matters.) Below, we create "dows" (for days-of-the-week), "dates" and "full_dates," but you can make whatever ordered observation/date variables you desire. And you need only one time variable:

    dows = ['Sunday', 'Monday', 'Tuesday', 'Wednesday','Thursday', 'Friday', 'Saturday']
    dates = ['2014-01-01', '2014-01-02', '2014-01-03', '2014-01-04', '2014-01-05', '2014-01-06', '2014-01-07']
    full_dates = ['Jan 1, 2014', 'Jan 2, 2014', 'Jan 3, 2014', 'Jan 4, 2014', 'Jan 5, 2014', 'Jan 6, 2014', 'Jan 7, 2014']

This is sufficient to package up your data into a SimpleTimeSeries object:

    require 'simple_time_series'
    my_data = SimpleTimeSeries.new(:time_vars => {'dows' => dows,
                                                  'dates' => dates,
                                                  'full_dates' => full_dates},
                                   :data_vars => {'pizzas' => pizzas,
                                                  'miles' => miles,
                                                  'tasks_done' => tasks_done})

You can now easily access the value of any data variable for any value of one of your time variables via xxx_on methods created for each of your data_vars (here called 'pizzas_on,' 'miles_on' and 'tasks_done_on'):

    puts "Pizzas eaten on Tuesday: #{my_data.pizzas_on('Tuesday')}" # prints 1
    puts "Pizzas eaten on 2014-01-03: #{my_data.pizzas_on('2014-01-03')}" # prints 1
    puts "Pizzas eaten on 'Jan 3, 2014': #{my_data.pizzas_on('Jan 3, 2014')}" # prints 1

    puts "Miles run on Friday: #{my_data.miles_run_on('Friday')}" # prints 12.2
    puts "Miles run on 2014-01-06: #{my_data.miles_run_on('2014-01-06')}" # prints 12.2
    puts "Miles run on 'Jan 6, 2014': #{my_data.miles_run_on('Jan 6, 2014')}" # prints 12.2

    puts "Tasks done on Saturday: #{my_data.tasks_done_on('Saturday')}" # prints 0
    puts "Tasks done on 2014-01-07: #{my_data.tasks_done_on('2014-01-07')}" # prints 0
    puts "Tasks done on 'Jan 7, 2014': #{my_data.tasks_done_on('Jan 7, 2014')}" # prints 0

You can get the same values by calling SimpleTimeSeries#find with two arguments, first the data_var name and then the time_var value:

    puts "Pizzas eaten on 'Jan 2, 2014': #{my_data.find('pizzas', 'Jan 2, 2014')}" # prints 0
    puts "Miles on Friday: #{my_data.find('miles', 'Friday')}" # prints 12.2
    puts "Miles on 2014-01-05: #{my_data.find('miles','2014-01-05')}" # prints 1.2
    puts "Tasks done on Wednesday: #{my_data.find('tasks_done', 'Wednesday')}" # prints 14
    puts "Tasks done on 2014-01-05: #{my_data.find('tasks_done', '2014-01-05')}" # prints 3

You can change the values associated with any data variable by setting the value to a different array:

    my_data.pizzas = [4, 6, 3, 2, 3.5, 7, 2]
    puts "Pizzas eaten on Tuesday: #{my_data.pizzas_on('Tuesday')}" # prints 3

Currently, SimpleTimeSeries assumes all variable arrays have equal lengths and represent the same sequence of observations. Though the gem says "time series," it should work with any kind of sequential data.

## Disclaimer

This began as a simple code example for a collague who needed to do something similar. When he said he might actually use it, I decided to create this gem. But it's really simple, with very basic functionality.

## Contributing

1. Fork it ( http://github.com/JamesLavin/simple_time_series/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Acknowledgements

Thanks to my employer, Hedgeye, for letting me create and publish this.
