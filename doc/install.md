# NoCMS Blocks

## Installation

To install the gem just include in your Gemfile:

```ruby
gem "nocms-blocks"
```

If you're brave and want to use the last development version you can use:

```ruby
gem "nocms-blocks", git: 'git@github.com:simplelogica/nocms-blocks.git'
```

Once the gem is installed you can import all the migrations:

```
rake no_cms_blocks:install:migrations
```

## Configuration

Once you installed it you should run the `nocms:blocks` initializer in order to
create the configuration initializer.

```
rails g nocms:blocks
```

This will create a `config/initializer/nocms/blocks.rb` where you can set up
two configurations:

* cache_enabled: You can enable/disable grafment cache for all the block
  layouts. This setting can be overriden by a particular block layout.
* block_layouts: All the layout configuration. You can see more info about the
  layouts in [the layouts section of the documentation](./layouts.md).
* templates: Define templates and zones where the blocks can be assigned so we
  can have some organization in our contents. You can see more info about the
  templates and their zones in [the templates section of the
  documentation](./templates.md).

### Database serializer

An special setting is the database serializer that will control how the block
fields are serialized into the database.

The whole serialization relies on
`ActiveRecord::AttributeMethods::Serialization` and its `serialize` method, so
the options acepted as database serializer are the valid options for that
method (`Hash` and `JSON`) and `:hstore`.

**Take into account that once the serialization method is set you should not
change it.** If you do, you won't be able to unserialize the already saved blocks
and a lot of errors will appear.

The default database serializer is `Hash` as it was the one used from the
beginning in the gem. This serializer serializes the fields using the YAML
parser.

#### PostgreSQL HStore support

When using hstore you need to configure the database serializer as `:hstore`
before running migrations, as setting this database serializer will enable the
extension in the migration and create the hstore fields in the database.

Obviously, **you need PostgreSQL to configure hstore support**. Otherwise, your
database will complain when trying to create an hstore field in the migration.
