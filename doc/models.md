# NoCMS Blocks

## How do I include it in my models?

Blocks are thought to be independent and customizable modules of content that
can be created, edited or removed on their own, without dependency of any other
module or class.


Now you have your blocks configured, but... how do yo use them?. You need to
create a relationship between the blocks and your model and you have two ways to
do it.

### Direct relationship with blocks

You can create your own belongs_to/has_many relationship with the
`NoCms::Blocks::Block` model just as with any other Rails model.

The only thing required is to create a migration to create the relationship:

```
rails g migration AddPageToNoCmsBlocksBlock page:belongs_to
```

And creating the relationship in your model:

```ruby
class Page
   has_many :blocks, class_name: "NoCms::Blocks::Block"
end
```

Also, if you plan to use `fields_for` to manage your blocks from your model's edit form (or you are going to use the admin helper provided by this gem) you are going to need to accept nested attributes by adding:

```ruby
class Page
   has_many :blocks, class_name: "NoCms::Blocks::Block"
   accepts_nested_attributes_for :blocks
end
```

This was the only way in the first versions of the gem and it's used in the
nocms-pages gem.

However this is only recommended if your block can't be attached to more than
one model as you can find some issues (e.g. If you have a block attached to two
pages you can't change the position in just one page). If that's not the case we
recomend using block slots as explained later.


### Using slots

The `BlockSlot` model allows you to easily create relationships between the
blocks and any other model allowing you to organize them independently for each
model (e.g: you can have the same module in different positions in diffferent models).

For creating the relationship you just have to include the
`NoCms::Blocks::Concerns::ModelWithSlots` concern in the models and you're done.

```ruby
class Page
  include NoCms::Blocks::Concerns::ModelWithSlots
end
```
