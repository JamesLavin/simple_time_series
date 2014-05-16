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

Imagine you have recorded over the past week the number of pizzas consumed, the number of miles run, and the number of tasks done.

You have these stored in simple Ruby arrays (that you can name anything you want):

    pizzas = [0, 0, 1, 0, 0.5, 0, 2]
    miles = [2.2, 3.1, 0.0, 4.3, 1.2, 12.2, 2.3]
    tasks_done = [2, 3, 0, 14, 3, 11, 0]

To associate these observations with the days they belong to, you create arrays of days-of-the-week ("dows") and/or "dates". (You can put whatever time/date values in these arrays that you wish. Currently, however, only arrays named "dows" and "dates" are supported, but I will soon make it so the names you choose don't matter. Only their order in the array(s) matters.)

    dows = ['Sunday', 'Monday', 'Tuesday', 'Wednesday',
            'Thursday', 'Friday', 'Saturday']
    dates = ['2014-01-01', '2014-01-02', '2014-01-03',
             '2014-01-04', '2014-01-05', '2014-01-06', '2014-01-07']

This is sufficient to package up your data into a SimpleTimeSeries object:

    require 'simple_time_series'
    my_data = SimpleTimeSeries.new(:time_vars => {'dows' => dows,
                                                  'dates' => dates},
                                   :data_vars => {'pizzas' => pizzas,
                                                  'miles' => miles,
                                                  'tasks_done' => tasks_done})

You can now easily access the value of any data variable for any value of one of your time variables:

    puts "Pizzas on Tuesday: #{my_data.pizzas_on('Tuesday')}"
    puts "Pizzas on 2014-01-03: #{my_data.pizzas_on('2014-01-03')}"
    puts "Miles on Friday: #{my_data.find('miles', 'Friday')}"
    puts "Miles on 2014-01-05: #{my_data.find('miles','2014-01-05')}"
    puts "Tasks done on Friday: #{my_data.find('tasks_done', 'Friday')}"
    puts "Tasks done on 2014-01-05: #{my_data.find('tasks_done', '2014-01-05')}"

## Disclaimer

This began as a simple code example for a collague who needed to do something similar. When he said he might actually use it, I decided to create this gem. But it's really simple, with very basic functionality.

## Contributing

1. Fork it ( http://github.com/JamesLavin/simple_time_series/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
