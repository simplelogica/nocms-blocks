# NoCMS Blocks

## Cache

Since blocks are independent units of content, the standard Rails fragment cache
seemed to fit well with them. That's why the `render_block` helper decides
wether Rails cache should be used for rendering an individual block.

Cache for the blocks are configured at 3 levels:

1. The `render_block` helper may be called with a `cache_enabled` option set to
   true or false. This option will enable/disable the cache. This allow us to
   render a block without using the cache (maybe on a preview action).

  ```ruby
    render_block block, cache: false
  ```

2. In the blocks configuration we can enable/disable the cache for all the
   blocks of a kind. We just have to add the `cache_enabled` setting.

  ```ruby
  NoCms::Blocks.configure do |config|

    config.block_layouts = {
      'default' => {
        template: 'default',
        fields: {
          title: :string,
          body: :text
        },
        cache_enabled: false
      }
    }
  end
  ```

3. In the blocks configuration file we can enable/disable cache for all the
   blocks that doesn't have a cache_enabled setting. This configuration will be
   stored at `NoCms::Blocks.cache_enabled`

  ```ruby
  NoCms::Blocks.configure do |config|

    config.cache_enabled = true

  end
  ```

As a summary:

```ruby

  b = NoCms::Blocks::Block.new layout: 'default', title: 'Foo', description: 'Bar'
  NoCms::Blocks.cache_enabled # => true
  b.cache_enabled # => false, since the block configuration sets it to false
  render_block b # => This won't use fragment cache since this block layout have cache disabled

  b = NoCms::Blocks::Block.new layout: 'title-3_columns', title: 'Foo', description: 'Bar'
  NoCms::Blocks.cache_enabled # => true
  b.cache_enabled # => true, since this block configuration doesn't override NoCms::Block.cache_enabled
  render_block b # => This will use fragment cache since, by default, it's enabled for all blocks

  render_block b, cache_enabled: false # => This won't use fragment cache as the option in the helper overrides the block configuration

```
