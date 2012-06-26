[![Build Status](https://secure.travis-ci.org/softa/activerecord-postgres-hstore.png?branch=master)](http://travis-ci.org/softa/activerecord-postgres-hstore)

Goodbye serialize, hello hstore.
--------------------------------

You need dynamic columns in your tables. What do you do?

* Create lots of tables to handle it. Nice, now you’ll need more models and lots of additional sqls. Insertion and selection will be slow as hell.
* Use a noSQL database just for this issue. Good luck.
* Create a serialized column. Nice, insertion will be fine, and reading data from a record too. But, what if you have a condition in your select that includes serialized data? Yeah, regular expressions.

Requirements
------------

Postgresql 8.4+ (also tested with 9.0) with contrib and Rails 3. (It
might work on 2.3.x with minor patches…)  
On Ubuntu, this is easy: `sudo apt-get install postgresql-contrib-9.0`

On Mac <del> …you are screwed. Use a VM.  </del> you should use [the binary package kindly provided by EnterpriseDB](http://www.enterprisedb.com/products-services-training/pgdownload#osx)  
[Homebrew’s](https://github.com/mxcl/homebrew) Postgres installation also includes the contrib packages: `brew install postgres`

Notes for Rails 3.1 and above
-----------------------------

The master branch already support a custom serialization coder.  
If you want to use it just put in your Gemfile:

    gem 'activerecord-postgres-hstore', git: 'git://github.com/softa/activerecord-postgres-hstore.git'

If you install them gem from the master branch you also have to insert a
line in each model that uses hstore.  
Assuming a model called **Person**, with a **data** field on it, the
code should look like:

    class Person < ActiveRecord::Base
      serialize :data, ActiveRecord::Coders::Hstore
    end

Install
-------

Hstore is a PostgreSQL contrib type, [check it out first](http://www.postgresql.org/docs/9.2/static/hstore.html).

Then, just add this to your Gemfile:

`gem 'activerecord-postgres-hstore'`

And run your bundler:

`bundle install`

Make sure that you have the desired database, if not create it as the
desired user:

`createdb hstorage_dev`

Add the parameters to your database.yml (these are system dependant),
e.g.:

    development:
      adapter: postgresql
      host: 127.0.0.1
      database: hstorage_dev
      encoding: unicode
      username: postgres
      password: 
      pool: 5

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

`CREATE INDEX people_gist_data ON people USING GIST(data);`  
or  
`CREATE INDEX people_gin_data ON people USING GIN(data);`

To understand the difference between the two types of indexes take a
look at [PostgreSQL docs](http://www.postgresql.org/docs/9.2/static/textsearch-indexes.html).

Usage
-----

Once you have it installed, you just need to learn a little bit of new
sqls for selecting stuff (creating and updating is transparent).  
Find records that contains a key named 'foo’:

    Person.where("data ? 'foo'")

Find records where 'foo’ is equal to 'bar’:

    Person.where("data -> 'foo' = 'bar'")

This same sql is at least twice as fast (using indexes) if you do it
that way:

    Person.where("data > 'foo=>bar'")
  
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

Have fun.

Help
----

You can use issues in github for that. Or else you can reach us at
twitter: [@dbiazus](https://twitter.com/#!/dbiazus) or [@joaomilho](https://twitter.com/#!/joaomilho)

Note on Patches/Pull Requests
-----------------------------

* Fork the project.  
* Make your feature addition or bug fix.  
* Add tests for it. This is important so I don’t break it in a future version unintentionally.  
* Commit, do not mess with rakefile, version, or history.  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)  
* Send me a pull request. Bonus points for topic branches.

Copyright
---------

Copyright © 2010 Juan Maiz. See LICENSE for details.
