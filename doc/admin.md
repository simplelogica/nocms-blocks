# NoCMS Blocks

## Admin interface

Since blocks are always attached to another object there is no separate admin
interface for them.

Instead of a separate admin interface this engine includes a set of partials
that can be used to render it as a basic admin interface attachable to any edit
view of any object that has blocks attached.

```ruby
  <%= render 'no_cms/admin/blocks/blocks/index', f: f %>
```

To use it you will need to add two methods to your controller's helper:

* **block_form_classes**: receives a block and returns an array of classes that will be used in the block's admin layout
* **block_form_id**: receives a block and returns the id assigned to the block's admoin layout in the HTML.

### Block admin templates

Same way that a block has a partial that gets rendered in the public views it
has another partial to be rendered inside the admin views if you use the
no_cms/admin/blocks/blocks/index partial.

This partial must be found at `no_cms/admin/blocks/blocks` views folder and have
the name configured in the `template` setting of the block. This way, rendering
a 'title-3_columns' would render the partial
`/no_cms/admin/blocks/blocks/title_3_columns`.

This partial is a regular Rails partial (nothing special here). As an example,
this could be the content of our
`/no_cms/admin/blocks/blocks/title_3_columns.html.erb` partial:

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

### NoCms Admin

This partial is fully compatible with `nocms-admin` gem and works with the JS in
that engine that handles creation or modification of blocks.

To enable it just add the following code to your form view.

```ruby
<% content_for :ready_js do %>
  NoCMS.Admin.BlockHandler();
<% end %>
```
