# Spare

Stored procedure models for ActiveRecord. I work in an environment where stored procedures are used extensively. Many of these stored procedures implement business rules for inserting records and quite a few parameters. I needed a better way to models is objects than the current MO which was to concatenate strings can call the `ActiveRecord::Base.connection.execute` directly. This a very early version and right now only supports Rails 3.2 with Mysql.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spare'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spare

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/spare/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
