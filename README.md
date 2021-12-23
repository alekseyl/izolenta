# Izolenta
This is a set of migration helpers delivering delegated uniqueness in Postgres ( A fine approach to solve 'optimistic' singleton record creation problem over data-set with a noticeable not-HOT UPDATEs amount present in corresponding object lifecycle. Read more: https://leshchuk.medium.com/delegated-uniqueness-in-postgres-d0fa103f749c )

The idea of the gem and article originated from two things: 
- first I wanted to replace uniq index for optimistic objects creation with something less burdensome for DB.
- second I realised that trigger based solution for dialogs uniqueness I was using will fail to serve its purpose on a default PG isolaiton level.

The first thought was to use redis mutex approach, but it lacks the simplicity and is NOT hard solid as index solution. 
Its better than done without, but still a lot could happened to fail it eventually.  

So I ended up delegating UNIQUE constraint to a helper table whenever I really can win something from skipping uniq index over data set.

**What's up with the naming?** In russian 'izolenta' means electrical tape (or insulating tape) 
serving purpose of isolation ( electrical ) on some monkey patching fixing. 

As the idea of the gem: patching the data circuit with a 100% isolation. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'izolenta'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install izolenta

## Usage

```ruby
class YourMigration < ActiveRecord::Migration[5.0]
  def change
    delegate_uniqueness( :your_table_name, :column_name )
  end
end
```

## Development

```bash
docker-compose build

docker-compose run test /bin/bash
> service postgresql start && rake test
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alekseyl/izolenta. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/izolenta/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Izolenta project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/izolenta/blob/master/CODE_OF_CONDUCT.md).
