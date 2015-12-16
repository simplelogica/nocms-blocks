# NoCMS Blocks

## How do I make some PR?

1. [Behave yourself](./CODE_OF_CONDUCT.md)
2. Clone the repo
3. Commit your changes in a new branch.
4. Test your changes in all the [Appraisals](https://github.com/thoughtbot/appraisal). Notice that using appraisals is mandatory as no database gem is listed in the default gemfile.

The following considerations must be observed when testing your change:

- Test that your changes don't break any right behaviour from the tests.

- Test that any new feature is properly tested.

- If some feature is only appliable in some Rails version or database you should
  make sure that any other appraisal is still working. You can limit your new
  feature by using `Rails.version` and `NoCms::Blocks.installed_db_gem`.

- Test in every created appraisal or explain why some appraisal is breaking the
  tests. As an example, hstore support testing would break MySQL appraisals
  because MySQL doesn't support hstore.

- Test your feature for every database serializers (Hash, JSON and hstore right
  now). In order to do this you must set an environment variable with the
  serializer used for testing.

The following ones are the appraisals/database serializers being tested right now:

- `SERIALIZER=JSON appraisal rspec`
- `SERIALIZER=Hash appraisal rspec`
- `SERIALIZER=hstore appraisal rails-4-0-pgsql rspec`
- `SERIALIZER=hstore appraisal rails-4-1-pgsql rspec`
- `SERIALIZER=hstore appraisal rails-4-2-pgsql rspec`

Notice hstore can't be tested with any mysql appraisal.

To test them you should create database and run migrations in the following
appraisals:

- `SERIALIZER=JSON appraisal rake db:create RAILS_ENV=test`
- `SERIALIZER=JSON appraisal rake db:migrate RAILS_ENV=test`
- `SERIALIZER=Hash appraisal rake db:create RAILS_ENV=test`
- `SERIALIZER=Hash appraisal rake db:migrate RAILS_ENV=test`
- `SERIALIZER=hstore appraisal rails-4-0-pgsql rake db:create RAILS_ENV=test`
- `SERIALIZER=hstore appraisal rails-4-0-pgsql rake db:migrate RAILS_ENV=test`

Finally, ask for a pull request and we will be very grateful.
