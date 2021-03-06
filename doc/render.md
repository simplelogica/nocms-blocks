# NoCMS Blocks

## Rendering blocks in our templates

Blocks are rendered using the `render_block` or `render_block_slot` helpers
which control all the logic related with rendering a block, including fragment
cache control.

The `render_block_slot` helper is a wrapper of the `render_block` helper that
includes the block slot information in the cache key and the block slot as a
local variable (slot) for the partial.

In the end a partial is rendered using the block as a local variable to obtain
the information.

This partial must be found at the partials folder configured in the engine's
initializer using the `front_partials_folder` option. By default this folder will
be `no_cms/blocks/blocks` inside the `views` folder of yout application.

The partials name will also be configured in the `template` setting of the
block.

This way, rendering a 'title-3_columns' would render the partial
`/no_cms/blocks/blocks/title_3_columns`. If we configure
`NoCms::blocks.front_partials_folder` to be `my_skin/blocks` then it would
render the partial `my_skin/blocks/title_3_columns`.

This partial is a regular Rails partial (nothing special here). As an example,
this could be the content of our
`/no_cms/blocks/blocks/title_3_columns.html.erb` partial:

```erb
<div class='columns_block'>
  <h2 class="title"><%= block.title %></h2>
  <p class="column_1"><%= block.column_1 %></p>
  <p class="column_2"><%= block.column_2 %></p>
  <p class="column_3"><%= block.column_3 %></p>
</div>
```

As you can see, the partial has a `block` variable containing the block object
you are rendering.

Other local variables can be declared and sent using a locals option when
calling the `render_block` method:

```ruby
render_block block, locals: { user: current_user }
```

And, as with any other partial, you can use them inside.

```erb
<div class='columns_block'>
  <h1>This is just for you <%= user.name %>!!</h2>
  <h2 class="title"><%= block.title %></h2>
  <p class="column_1"><%= block.column_1 %></p>
  <p class="column_2"><%= block.column_2 %></p>
  <p class="column_3"><%= block.column_3 %></p>
</div>
```


Since this is plain old rails you can do everything you can do with a partial
(e.g. having a `/no_cms/blocks/blocks/title_3_columns.en.html.erb` for the
english version and a `/no_cms/blocks/blocks/title_3_columns.es.html.erb` for
the spanish one).


### Nested blocks

As seen before you can nest some blocks inside others.

However, displaying the nested blocks is your responsability. You should use the
`render_block` or `render_block_slot` helpers depending on whether you're using
slots.

A rather typical template would be:

```erb
<h2 class="title"><%= block.title %></h2>
<div class='nested_block'>
  <% if local_assigns.has_key? :slot %>
    <% slot.children.each do |c| %>
      <%= render_block_slot c %>
    <% end -%>
  <% else %>
    <% block.children.each do |c| %>
      <%= render_block c %>
    <% end -%>
  <% end -%>
</div>
```

### Lazy blocks

As seen when we [defined templates and zones](./doc/templates.md) some blocks
must be loaded not directly in the view but through some lazy loading technique,
such as an ajax request and some front-end framework.

That's why we must configure a different view for the lazy loading the block
where we show an skeleton of the block or whatever conde is required to load it
after the page is ready.

The partial will be configured as the `skeleton_template` setting of the block
configuration. This is not a mandatory attribute and if it's not defined it will
take the value `default`.

The folder for skeletons partials will ve configured also separately in the
variable `NoCms::Blocks.front_skeletons_folder`. This way, you can completely
separate your regular and your skeleton templates.

The `render_block_slot` helper will check the block and template configurations
to decide wether it must use the regular templates or the skeleton ones.

You could also force it through the `render_block_slot` or the `render_block`
helpers sending the `lazy_block` option as true.

Once the skeleton is rendered, it's up to you how to manage it!

### Custom CSS Files

A block can have its own CSS files so the application.css doesn't get too big.
You can configure a block to have multiple css files suitable for differente
devices or mediaqueries.

This configuration comes from the `css_templates` setting in a block
configuration where you can set an array of css file names, such as:

```
NoCms::Blocks.configure do |config|
  config.block_layouts = {
    'title-long_text' => {
      template: 'title-long_text',
      fields: {
        title: :string,
        body: :text
      },
      css_templates: [
        'title-long_text_desktop',
        'title-long_text_mobile',
        'title-long_text_tablet',
        'title-long_text_all'
      ]
    }
  }
end
```

In this configuration the `title-long_text` has four different css files. This
CSS files will not be automatically created and they must be created and
included in the asset pipeline by hand.

The name of the css_template uses the final suffix as an indicator of the
mediaquery that should apply to the file. In the example, for
`title-long_text_desktop` will apply the `desktop` mediaquery, for
`title-long_text_mobile` the `mobile` one and so on.

These mediaqueries are configured by the `css_mediaqueries` of the
`NoCms::Blocks` engine by default the value is

```
css_mediaqueries = {
  mobile: 'only screen and (max-width: 767px)',
  tablet: 'only screen and (min-width: 768px) and (max-width: 1024px)',
  desktop: 'only screen and (min-width: 1025px)',
  all: 'All'
}
```

The helper `stylesheet_link_tags_for_block` will return and string with all the
`stylesheet_link_tag` for the css files. In the example:

```
<link href="/stylesheets/no_cms/blocks/title-long_text/title-long_text_desktop.css" media="only screen and (min-width: 1025px)" rel="stylesheet" />
<link href="/stylesheets/no_cms/blocks/title-long_text/title-long_text_mobile.css" media="only screen and (max-width: 767px)" rel="stylesheet" />
<link href="/stylesheets/no_cms/blocks/title-long_text/title-long_text_tablet.css" media="only screen and (min-width: 768px) and (max-width: 1024px)" rel="stylesheet" />
<link href="/stylesheets/no_cms/blocks/title-long_text/title-long_text_all.css" media="All" rel="stylesheet" />
```
