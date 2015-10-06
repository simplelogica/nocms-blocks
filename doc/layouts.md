# NoCMS Blocks

## Layouts

A block layout is the configuration that defines a kind of block that can be
used in your app. As an example, you can have layouts like "block with a text
and an image", "block with link to a news item", "block with the next events in
my agenda".

Layouts define which information a block will contain, which fields will respond
to, wether the block can be cached and (through rails standard partials) how it
will be rendered and both in the public section of your web and in the admin
interface.

### How to configure a new layout

`nocms-blocks` gem has a configuration written in plain ruby that can be
modified to create new layouts.


`NoCms::Blocks.block_layouts` variable contains a hash with all the layouts
available in your app. This hash can be set in an initializer like the following
one:

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

This creates 3 different block layouts with different fields.

`NoCms::Blocks.block_layouts` is a plain old hash so we can play with it just
like with any other hash (i.e. splitting layout definitions in various files and
inserting new values in the hash whenever we want).

The layout has the following options:

* template: This is the name of partial that will be used to render the block.
  You can see more details in the rendering section.

* fields: All the fields that will be declared in the block. More details later.

* allow_nested_blocks: A block can include nested blocks (e.g. A slideshow block
  with slide ones). This setting can be used by the admin interface in order to
  decide wether the block can accept children.

* nest_levels: Some layout may not be nestable, or useful only in certain
  nesting level. Once again, this setting can be used by the admin interface to
  hide certain layouts in nested blocks. When blank, it's assumed there's no
  restriction.

* cache_enabled: When setting cache_enabled you will be **overriding** the
  global cache_enabled setting. If you don't set a cache setting then it will
  use the global cache setting specified in the `NoCms::Blocks.cache_enabled`
  variable.

#### Models in the fields

Notice that fields doesn't have to be only strings, integers or other "simple"
values. They can be also classes.

For storing an object you only have to put the class in the `type` configuration
in the field. E.g in the following layout:

```ruby
  'logo-caption' => {
    template: 'logo_caption',
    fields: {
      caption: :string,
      logo: TestImage
    }
  }
```

the `logo` attribute is a `TestImage` object.

Currently there are 3 kind of objects supported through 3 different serializers:

  - Date, DateTime, Time: using the DateSerializer.
  - ActiveRecord objects: using the ActiveRecordSerializer.
  - ActiveResource objects: using the ActiveResourceSerializer.

You can write your own Serializer and add it to the NoCms::Blocks.serializers
hash.

Look at the `app/serializers` folder and the
`lib/no_cms/blocks/configuration.rb` files.

#### Multiple models in a field

Both ActiveRecord and ActiveResource fields can be configured to store more than
one object. In order to enable that you just have to configure the field with
`multiple: true`. E.g in the following layout:

```ruby
  'logo-caption' => {
    template: 'logo_caption',
    fields: {
      caption: :string,
      logo: TestImage,
      slides: { type: TestImage, multiple: true}
    }
  }
```

A block with layout will respond to the following methods:

```ruby
  block.logo
  block.logo_id
  block.slides
  block.slides_ids
```

### How to use a layout

A `NoCms::Blocks::Block` instance has a layout attribute that stores which
layout it has assigned and defines which attributes are accessible for this
block.

Following the example of the previous configuration, if we have a block with a
`default` layout we can do `block.title`.

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

### Generators

A layout can involve different files to be created so there's a generator that
will create them for you. Using it is optional and all the configuration or
files can be created by hand.

```
rails g nocms:blocks:layout LAYOUT_NAME
```

This will create the following files:

1. `config/initializers/nocms/blocks/LAYOUT_NAME.rb`: An initializer where you
   can configure the layout (more info on next section).
2. `app/views/no_cms/blocks/blocks/_LAYOUT_NAME.html.erb`: Public template for
   the block (more info on next section).
3. `app/views/no_cms/admin/blocks/blocks/_LAYOUT_NAME.html.erb`: Template for
   block administration. You can choose not to use it depending on which admin
   interface you're using.
4. `app/assets/stylesheets/no_cms/blocks/_LAYOUT_NAME.scss`: Stylesheet asset so
   you can organize your SCSS code. Of course, you can not use it, but we
   strongly recommend trying to maintain styles from a block in a separated
   stylesheet. Notice that you must import (`@import
   "app/assets/stylesheets/no_cms/blocks/_LAYOUT_NAME.scss"`) it from your
   application.css.scss or where it should be used.
