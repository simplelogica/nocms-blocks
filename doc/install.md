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
