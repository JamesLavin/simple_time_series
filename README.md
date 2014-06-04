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

You can view all the values associated with any variable:

    my_data.miles # prints [2.2, 3.1, 0.0, 4.3, 1.2, 12.2, 2.3]

You can also get the array of values with #current:

    my_data.current('miles') # prints [2.2, 3.1, 0.0, 4.3, 1.2, 12.2, 2.3]

You can change all the values associated with any data variable by setting the value to a different array:

    my_data.pizzas = [4, 6, 3, 2, 3.5, 7, 2]
    puts "Pizzas eaten on Tuesday: #{my_data.pizzas_on('Tuesday')}" # prints 3

You can change a single value in any data variable by calling #set:

    my_data.set('pizzas', 'Tuesday', 44)

This will change the value:

  puts my_data.pizzas_on('Tuesday') # prints 44
  puts my_data.pizzas_on('2014-01-03') # prints 44
  puts my_data.pizzas_on('Jan 3, 2014') # prints 44

A second example of #set:

  my_data.set('tasks_done', 'Saturday', 77)
  puts my_data.tasks_done_on('Saturday') # prints 77
  puts my_data.tasks_done_on('2014-01-07') # prints 77
  puts my_data.tasks_done_on('Jan 7, 2014') # prints 77

You can use #set to build up a data variable from an empty array. Begin by assigning an empty array to a data_var:

    my_data2 = SimpleTimeSeries.new(:time_vars => {'dows' => dows,
                                                  'dates' => dates,
                                                  'full_dates' => full_dates},
                                    :data_vars => {'empty' => []}

You can then set individual values using #set till you've filled in all values:

    my_data2.set('empty', 'Jan 1, 2014', 1)
    my_data2.set('empty', 'Monday', 2)
    my_data2.set('empty', '2014-01-03', 3)
    my_data2.set('empty', 'Jan 4, 2014', 4)
    my_data2.set('empty', 'Thursday', 5)
    my_data2.set('empty', '2014-01-06', 6)
    my_data2.set('empty', 'Jan 7, 2014', 7)

my_data2.empty now equals [1, 2, 3, 4, 5, 6, 7]

You can also create new time variables and data variables after you have created your SimpleTimeSeries object.

Here's how you can create and use a new time variable:

    my_data.new_time_var('short_dow',['Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat'])

    puts my_data.tasks_done_on('Fri') # prints 11
    puts my_data.pizzas_on('Thurs') # prints 0.5

Here's how you can create and use a new data variable:

    my_data.new_data_var('hours_of_tv',[7, 3, 3.5, 3, 4, 6.5, 11])

    puts my_data.hours_of_tv # prints [7, 3, 3.5, 3, 4, 6.5, 11]
    puts my_data.hours_of_tv_on('Friday') # prints 6.5
    puts my_data.hours_of_tv_on('2014-01-01') # prints 7

You can create new time and data variables and use them together:

    my_data.new_time_var('short_dow',['Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat'])
    my_data.new_data_var('hours_of_tv',[7, 3, 3.5, 3, 4, 6.5, 11])

    puts my_data.hours_of_tv_on('Fri') # prints 6.5
    puts my_data.hours_of_tv_on('Sun') # prints 7

You can extract a subset of any data variable by using any time variable values as indexes for the first and last elements you want in your subset:

    my_data.pizzas_subset('Tuesday','Thursday') # returns [1, 0, 0.5]
    my_data.tasks_done_subset('Jan 2, 2014','Jan 5, 2014') # returns [3, 0, 14, 3]

You can even mix different time variables together:

    my_data.tasks_done_subset('Monday','Jan 5, 2014') # returns [3, 0, 14, 3]
    my_data.pizzas_subset('Jan 1, 2014','2014-01-04') # returns [0, 0, 1, 0]

You can also set a subset of values

    my_data.pizzas_subset_set('Tuesday','Thursday', [7, 8, 9.5])
    my_data.pizzas_subset('Tuesday','Thursday') # returns [7, 8, 9.5]
    my_data.pizzas_subset('2014-01-03','Jan 5, 2014') # returns [7, 8, 9.5]
    my_data.pizzas # returns [0, 0, 7, 8, 9.5, 0, 2]

And you can get an array of differences between consecutive observations for any data_var:

    my_data.tasks_done_diff # returns [nil, 1, -3, 14, -11, 8, -11]
    my_data.pizzas_diff # returns [nil, 0, 1, -1, 0.5, -0.5, 2]    

You can also grab subsets of these arrays of differences. It returns a single value if you request a single value:

    my_data.tasks_done_diff('Saturday') # returns -11
    my_data.tasks_done_diff('Sunday') # returns nil (because the first time slot cannot have a difference)
    my_data.pizzas_diff('Saturday') # returns 2
    my_data.pizzas_diff('2014-01-01') # returns nil (again, because the first time slot has no difference)
    my_data.pizzas_diff('Jan 4, 2014') # returns -1

It returns an array if you ask for a range of values:

    my_data.tasks_done_diff('Sunday','Monday') # returns [nil, 1]
    my_data.tasks_done_diff('Tuesday','Saturday') # returns [-3, 14, -11, 8, -11]

Currently, SimpleTimeSeries assumes all variable arrays have equal lengths and represent the same sequence of observations. Though the gem says "time series," it should work with any kind of sequential data.

## Disclaimer

This began as a simple code example for a collague who had programmed something similar but in a manual, repetitive way with integer-indexed subscript references to rows and columns. The code worked but had become an unmaintainable, non-extensible monster. When he said he might actually use my code example, I turned it into this gem. It's really simple, with very basic functionality, but he has now started using this, so I may progressively add bells and whistles.

## Contributing

1. Fork it ( http://github.com/JamesLavin/simple_time_series/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Todo

1. Enable cumulative sum on any data_var
2. Enable range extraction via data_var[start_time, end_time]. This currently works as data_var_subset(start_time, end_time).
3. Enable setting values for a range via data_var[start_time, end_time]=

## Acknowledgements

Thanks to my employer, Hedgeye, for letting me create and publish this.
