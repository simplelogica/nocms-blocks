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


#### Nested blocks

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
