#Goodbye serialize, hello hstore. [![Build Status](https://secure.travis-ci.org/engageis/activerecord-postgres-hstore.png?branch=master)](http://travis-ci.org/engageis/activerecord-postgres-hstore)

You need dynamic columns in your tables. What do you do?

* Create lots of tables to handle it. Nice, now you’ll need more models and lots of additional sqls. Insertion and selection will be slow as hell.
* Use a noSQL database just for this issue. Good luck.
* Create a serialized column. Nice, insertion will be fine, and reading data from a record too. But, what if you have a condition in your select that includes serialized data? Yeah, regular expressions.

##Note about 0.7

I have decided to clean up the old code and provide only a custom serializer in this new version.

In order to acomplish this I had to drop support for older versions of Rails (3.0 and earlier) and also
remove some monkey patches that added functionality to the Hash, String, and some ActiveRecord objects.
This monkey patches provided methods such as Hash\#to\_hstore and String\#from\_hstore.


**If you rely on this feature please stick to 0.6 version** and there is still a branch named 0.6 to which you can submit your pull requests.

##Requirements

Postgresql 8.4+ with contrib and Rails 3.1+ (If you want to try on older rails versions I recommend the 0.6 and ealier versions of this gem)
On Ubuntu, this is easy: `sudo apt-get install postgresql-contrib-9.1`

On Mac you have a couple of options:

* [the binary package kindly provided by EnterpriseDB](http://www.enterprisedb.com/products-services-training/pgdownload#osx)
* [Homebrew’s](https://github.com/mxcl/homebrew) Postgres installation also includes the contrib packages: `brew install postgres`
* [Postgres.app](http://postgresapp.com/)

##Install


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

##Usage

This gem only provides a custom serialization coder.
If you want to use it just put in your Gemfile:

    gem 'activerecord-postgres-hstore'

Now add a line (for each hstore column) on the model you have your hstore columns.
Assuming a model called **Person**, with a **data** field on it, the
code should look like:

```ruby
class Person < ActiveRecord::Base
  serialize :data, ActiveRecord::Coders::Hstore
end
```

This way, you will automatically start with an empty hash that you can write attributes to.

    irb(main):001:0> person = Person.new
    => #<Person id: nil, name: nil, data: {}, created_at: nil, updated_at: nil>
    irb(main):002:0> person.data['favorite_color'] = 'blue'
    => "blue"

###Querying the database

Now you just need to learn a little bit of new
sqls for selecting stuff (creating and updating is transparent).
Find records that contains a key named 'foo’:

    Person.where("data ? 'foo'")

Find records where 'foo’ is equal to 'bar’:

    Person.where("data -> 'foo' = 'bar'")

This same sql is at least twice as fast (using indexes) if you do it
that way:

    Person.where("data @> 'foo=>bar'")

Find records where 'foo’ is not equal to 'bar’:

    Person.where("data -> 'foo' <> 'bar'")

Find records where 'foo’ is like 'bar’:

    Person.where("data -> 'foo' LIKE '%bar%'")

If you need to delete a key in a record, you can do it that way:

    person.destroy_key(:data, :foo)

This way you’ll also save the record:

    person.destroy_key!(:data, :foo)

The destroy\_key method returns 'self’, so you can chain it:

    person.destroy_key(:data, :foo).destroy_key(:data, :bar).save

But there is a shortcuts for that:

   person.destroy_keys(:data, :foo, :bar)

And finally, if you need to delete keys in many rows, you can:

    Person.delete_key(:data, :foo)

and with many keys:

    Person.delete_keys(:data, :foo, :bar)

##Caveats

hstore keys and values have to be strings. This means `true` will become `"true"` and `42` will become `"42"` after you save the record. Only `nil` values are preserved.

It is also confusing when querying:

    Person.where("data -> 'foo' = :value", value: true).to_sql
    #=> SELECT "people".* FROM "people" WHERE ("data -> 'foo' = 't'") # notice 't'

To avoid the above, make sure all named parameters are strings:

    Person.where("data -> 'foo' = :value", value: some_var.to_s)

Have fun.

##Test Database

To have hstore enabled when you load your database schema (as happens in rake db:test:prepare), you
have two options.

The first option is creating a template database with hstore installed and set the template option
in database.yml to that database.

The second option is to uncomment or add the following line in config/application.rb

    config.active_record.schema_format = :sql

This will change your schema dumps from Ruby to SQL. If you're
unsure about the implications of this change, we suggest reading this
[Rails Guide](http://guides.rubyonrails.org/migrations.html#schema-dumping-and-you).

##Help

You can use issues in github for that. Or else you can reach us at
twitter: [@dbiazus](https://twitter.com/#!/dbiazus) or [@joaomilho](https://twitter.com/#!/joaomilho)

##Note on Patches/Pull Requests


* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don’t break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

##Copyright

Copyright © 2010 Juan Maiz. See LICENSE for details.
