# Goodbye serialize, hello hstore.

[![Build Status](https://secure.travis-ci.org/diogob/activerecord-postgres-hstore.svg?branch=master)](http://travis-ci.org/diogob/activerecord-postgres-hstore)
[![Code Climate](https://codeclimate.com/github/diogob/activerecord-postgres-hstore.svg)](https://codeclimate.com/github/diogob/activerecord-postgres-hstore)

You need dynamic columns in your tables. What do you do?

* Create lots of tables to handle it. Nice, now you’ll need more models and lots of additional sqls. Insertion and selection will be slow as hell.
* Use a noSQL database just for this issue. Good luck.
* Create a serialized column. Nice, insertion will be fine, and reading data from a record too. But, what if you have a condition in your select that includes serialized data? Yeah, regular expressions.

## Common use cases

Add settings to users, like in rails-settings or HasEasy.

```ruby
class User < ActiveRecord::Base
  serialize :settings, ActiveRecord::Coders::Hstore
end
user = User.create settings: {theme: 'navy'}
user.settings['theme']
```

## Note about Rails 4

If you are using Rails 4 you don't need this gem as ActiveRecord 4 provides HStore type support out of the box.  ActiveRecord will see your HStore column and do all of the work for you.  **Additional code is no longer needed.**

You can test it with a migration like this:
```ruby
class CreateTest < ActiveRecord::Migration
  def change
    create_table :tests do |t|
      t.hstore :data
    end
  end
end
```

Its model:
```ruby
class Test < ActiveRecord::Base
  # before Rails 4, we'd have to this here:
  # serialize :data, ActiveRecord::Coders::Hstore
end
```

Then you can use the hash field straight away:
```ruby
irb(main):003:0> t = Test.new data: {a: 1, b:2}
=> #<Test id: nil, data: {"a"=>"1", "b"=>"2"}>
irb(main):004:0> t.save!
   (0.3ms)  BEGIN
  SQL (2.3ms)  INSERT INTO "tests" ("data") VALUES ($1) RETURNING "id"  [["data", "\"a\"=>\"1\",\"b\"=>\"2\""]]
   (0.5ms)  COMMIT
=> true
irb(main):005:0> t
=> #<Test id: 1, data: {"a"=>"1", "b"=>"2"}>
irb(main):006:0> t.data
=> {"a"=>"1", "b"=>"2"}
irb(main):007:0> t.data['a']
=> "1"
```

For more information take a look [here](http://jes.al/2013/11/using-postgres-hstore-rails4/)

## Note about 0.7

I have decided to clean up the old code and provide only a custom serializer in this new version.

In order to acomplish this I had to drop support for older versions of Rails (3.0 and earlier) and also
remove some monkey patches that added functionality to the Hash, String, and some ActiveRecord objects.
This monkey patches provided methods such as Hash\#to\_hstore and String\#from\_hstore.


**If you rely on this feature please stick to 0.6 version** and there is still a branch named 0.6 to which you can submit your pull requests.

## Requirements

Postgresql 8.4+ with contrib and Rails 3.1+ (If you want to try on older rails versions I recommend the 0.6 and ealier versions of this gem)
On Ubuntu, this is easy: `sudo apt-get install postgresql-contrib-9.1`

On Mac you have a couple of options:

* [the binary package kindly provided by EnterpriseDB](http://www.enterprisedb.com/products-services-training/pgdownload#osx)
* [Homebrew’s](https://github.com/mxcl/homebrew) Postgres installation also includes the contrib packages: `brew install postgres`
* [Postgres.app](http://postgresapp.com/)

## Install


Hstore is a PostgreSQL contrib type, [check it out first](http://www.postgresql.org/docs/9.2/static/hstore.html).

Then, just add this to your Gemfile:

`gem 'activerecord-postgres-hstore'`

And run your bundler:

`bundle install`

Now you need to create a migration that adds hstore support for your
PostgreSQL database:

`rails g hstore:setup`

Run it:

`rake db:migrate`

Finally you can create your own tables using hstore type. It’s easy:

    rails g model Person name:string data:hstore
    rake db:migrate

You’re done.
Well, not yet. Don’t forget to add indexes. Like this:

```sql
CREATE INDEX people_gist_data ON people USING GIST(data);
```
or
```sql
CREATE INDEX people_gin_data ON people USING GIN(data);
```

This gem provides some functions to generate this kind of index inside your migrations.
For the model Person we could create an index (defaults to type GIST) over the data field with this migration:

```ruby
class AddIndexToPeople < ActiveRecord::Migration
  def change
    add_hstore_index :people, :data
  end
end
```

To understand the difference between the two types of indexes take a
look at [PostgreSQL docs](http://www.postgresql.org/docs/9.2/static/textsearch-indexes.html).

## Usage

This gem only provides a custom serialization coder.
If you want to use it just put in your Gemfile:

```ruby
gem 'activerecord-postgres-hstore'
```

Now add a line (for each hstore column) on the model you have your hstore columns.
Assuming a model called **Person**, with a **data** field on it, the
code should look like:

```ruby
class Person < ActiveRecord::Base
  serialize :data, ActiveRecord::Coders::Hstore
end
```

This way, you will automatically start with an empty hash that you can write attributes to.

```ruby
irb(main):001:0> person = Person.new
=> #<Person id: nil, name: nil, data: {}, created_at: nil, updated_at: nil>
irb(main):002:0> person.data['favorite_color'] = 'blue'
=> "blue"
```

### Querying the database

Now you just need to learn a little bit of new
sqls for selecting stuff (creating and updating is transparent).
Find records that contains a key named 'foo’:

```ruby
Person.where("data ? 'foo'")
```

Find records where 'foo’ is equal to 'bar’:

```ruby
Person.where("data -> 'foo' = 'bar'")
```

This same sql is at least twice as fast (using indexes) if you do it
that way:

```ruby
Person.where("data @> 'foo=>bar'")
```

Find records where 'foo’ is not equal to 'bar’:

```ruby
Person.where("data -> 'foo' <> 'bar'")
```

Find records where 'foo’ is like 'bar’:

```ruby
Person.where("data -> 'foo' LIKE '%bar%'")
```

If you need to delete a key in a record, you can do it that way:

```ruby
person.destroy_key(:data, :foo)
```

This way you’ll also save the record:

```ruby
person.destroy_key!(:data, :foo)
```

The destroy\_key method returns 'self’, so you can chain it:

```ruby
person.destroy_key(:data, :foo).destroy_key(:data, :bar).save
```

But there is a shortcuts for that:

```ruby
person.destroy_keys(:data, :foo, :bar)
```

And finally, if you need to delete keys in many rows, you can:

```ruby
Person.delete_key(:data, :foo)
```

and with many keys:

```ruby
Person.delete_keys(:data, :foo, :bar)
```

## Caveats

hstore keys and values have to be strings. This means `true` will become `"true"` and `42` will become `"42"` after you save the record. Only `nil` values are preserved.

It is also confusing when querying:

```ruby
Person.where("data -> 'foo' = :value", value: true).to_sql
#=> SELECT "people".* FROM "people" WHERE ("data -> 'foo' = 't'") # notice 't'
```

To avoid the above, make sure all named parameters are strings:

```ruby
Person.where("data -> 'foo' = :value", value: some_var.to_s)
```

Have fun.

## Test Database

To have hstore enabled when you load your database schema (as happens in rake db:test:prepare), you
have two options.

The first option is creating a template database with hstore installed and set the template option
in database.yml to that database. If you use the template1 database for this you don't even need to
set the template option, but the extension will be installed in all your databases from now on 
by default. To install the extension in your template1 database you could simply run:

```ruby
psql -d template1 -c 'create extension hstore;'
```

The second option is to uncomment or add the following line in config/application.rb

```ruby
config.active_record.schema_format = :sql
```

This will change your schema dumps from Ruby to SQL. If you're
unsure about the implications of this change, we suggest reading this
[Rails Guide](http://guides.rubyonrails.org/migrations.html#schema-dumping-and-you).

## Help

You can use issues in github for that. Or else you can reach us at
twitter: [@dbiazus](https://twitter.com/#!/dbiazus) or [@joaomilho](https://twitter.com/#!/joaomilho)

## Note on Patches/Pull Requests


* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don’t break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright © 2010 Juan Maiz. See LICENSE for details.
