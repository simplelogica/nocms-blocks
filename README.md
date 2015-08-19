# NoCMS Blocks

## What's this?

This is a Rails engine with a basic functionality of customizable blocks of content attachable to objects. It's not attached to any particular CMS so you can use it freely within your Rails application without too much dependencies.

## How do I install it?

Just include in your Gemfile:

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

And run the initializer:

```
rails g nocms:blocks
```

## How does it works?

Blocks are thought to be independent and customizable modules of content that can be created, edited or removed on their own, without dependency of any other module or class.

### Block layouts

In NoCMS Blocks, block layouts define two main things:

1. What kind of information a block contains and other settings (i.e. cache settings).
2. How this information is displayed on a view.

Block settings are configured in the file `config/initializers/nocms/blocks.rb`. In that file we declare all the available layouts for a block.

The following code

```ruby
NoCms::Blocks.configure do |config|

  config.block_layouts = {
    'default' => {
      template: 'default',
      fields: {
        title: :string,
        body: :text
      }
    },
    'title-3_columns' => {
      template: 'title_3_columns',
      fields: {
        title: :string,
        column_1: :text,
        column_2: :text,
        column_3: :text
      },
    },
    'logo-caption' => {
      template: 'logo_caption',
      fields: {
        caption: :string,
        logo: TestImage
      }
    }
  }

end
```

declares 3 layouts ('default', 'title-3_columns' and 'logo-caption'). Each layout has a template and some declared fields. These fields will be available in the ruby object for that block. As an example, if `@block` is an instance of the NoCms::Blocks::Block model which layout attribute is set to 'default' you will be able to do `@block.title`

```ruby
block = NoCms::Blocks::Block.new
block.layout = 'default'

block.title = 'a title'
block.title # => 'a title'

block.column_1 = 'a column' # => NoMethodError
block.column_1 # => NoMethodError


block.layout = 'title-3_columns'

block.title # => 'a title'
block.column_1 = 'a column'
block.column_1 # => 'a column'
block.body # => NoMethodError

block.layout = 'logo_caption'
block.title # => NoMethodError
block.logo = { name: 'testing logo' } # Currently this is the way to assign objects
block.logo.name # => 'testing logo'
block.logo.class # => TestImage
block.logo = TestImage.new name: 'testing logo' # Error! Currently assigning the object is not allowed :(
```

### Block templates

Blocks are rendered using the `render_block` helper which controls all the logic related with renderinf a block, including fragment cache control.

In the end a partial is rendered using the block as a local variable to obtain the information. This partial must be found at `no_cms/blocks/blocks` views folder and have the name configured in the `template` setting of the block. This way, rendering a 'title-3_columns' would render the partial `/no_cms/blocks/blocks/title_3_columns`.

This partial is a regular Rails partial (nothing special here). As an example, this could be the content of our  `/no_cms/blocks/blocks/title_3_columns.html.erb` partial:

```html
<div class='columns_block'>
  <h2 class="title"><%= block.title %></h2>
  <p class="column_1"><%= block.column_1 %></p>
  <p class="column_2"><%= block.column_2 %></p>
  <p class="column_3"><%= block.column_3 %></p>
</div>
```

As you can see, the partial has a `block` variable containing the block object you are rendering.

Since this is plain old rails you can do everything you can do with a partial (e.g. having a `/no_cms/blocks/blocks/title_3_columns.en.html.erb` for the english version and a `/no_cms/blocks/blocks/title_3_columns.es.html.erb` for the spanish one).

### Block Cache

Since blocks are independent units of content, the standard Rails fragment cache seemed to fit well with them. That's why the `render_block` helper decides wether Rails cache should be used for rendering an individual block.

Cache for the blocks are configured at 3 levels:

1. The `render_block` helper may be called with a `cache_enabled` option set to true or false. This option will enable/disable the cache. This allow us to render a block without using the cache (maybe on a preview action).

  ```ruby
    render_block block, cache: false
  ```

2. In the blocks configuration we can enable/disable the cache for all the blocks of a kind. We just have to add the `cache_enabled` setting.

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

3. In the blocks configuration file we can enable/disable cache for all the blocks that doesn't have a cache_enabled setting. This configuration will be stored at `NoCms::Blocks.cache_enabled`

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

## Where is the admin interface?

Since blocks are always attached to another object there ¡s no separate admin interface for them.

Instead of a separate admin interface this engine includes a set of partials that can be used to render it as a basic admin interface attachable to any edit view of any object that has blocks attached.

```ruby
  <%= render 'no_cms/admin/blocks/blocks/index', f: f %>
```

### NoCms Admin

This partial is fully compatible with `nocms-admin` gem and works with the JS in that engine that handles creation or modification of blocks.

To enable it just add the following code to your form view.

```ruby
<% content_for :ready_js do %>
  NoCMS.Admin.BlockHandler();
<% end %>
```

### Block admin templates

Same way that a block has a partial that gets rendered in the public views it has another partial to be rendered inside the admin views if you use the no_cms/admin/blocks/blocks/index partial.

This partial must be found at `no_cms/admin/blocks/blocks` views folder and have the name configured in the `template` setting of the block. This way, rendering a 'title-3_columns' would render the partial `/no_cms/admin/blocks/blocks/title_3_columns`.

This partial is a regular Rails partial (nothing special here). As an example, this could be the content of our  `/no_cms/admin/blocks/blocks/title_3_columns.html.erb` partial:

```html
<div class="row">
  <%= f.label :title %>
  <%= f.text_field :title %>
</div>

<div class="row">
  <%= f.label :column_1 %>
  <%= f.text_area :column_1 %>
</div>

<div class="row">
  <%= f.label :column_2 %>
  <%= f.text_area :column_2 %>
</div>

<div class="row">
  <%= f.label :column_3 %>
  <%= f.text_area :column_3 %>
</div>
```
