# NoCMS Blocks

## Templates and zones for blocks

It's usual that the blocks are assigned to placeholders of our views where they
belong. As an example, a view with a sidebar column may need some of the blocks
placed in the sidebar zone and others in the content one. It's even possible
that the layouts allowed in the sidebar may not be allowed in the content area
and viceversa.

This templates and zones can be defined in the [engine
configuration](./install.md), along with the layouts allowed in each zone.


NoCms::Blocks.configure do |config|

  config.templates = {

    'two-columns' => {
      blocks: [:general1, :general2],
      models: ["SlottedPage"],
      zones: {
        header: {
          blocks: [:header1, :header2]
        },
        body: {
          blocks: [:body]
        },
        sidebar: {
          blocks: [:sidebar1, :sidebar2]
        },
        footer: {
        }
      }
    }
  }
end

This configuration will create a `two-columns` template with 4 zones (`header`,
`body`, `sidebar`, `footer`).

### Assigning blocks to zones

`NoCms::Blocks::BlockSlot` and `NoCms::Blocks::Block` models have a
`template_zone` attribute where will be stored which zone every block belongs
to. You can fetch the slots and blocks for a zone using the `for_template_zone`
scope.

If you're attaching the blocks to a model (e.g. a `Page` model) of your own you
will need to store which template is used by the instance of your model. We will
come back later to this.

### Blocks restrictions

If you're using `NoCms::Blocks::BlockSlot` there's a validation that checks that
only blocks from valid layouts are attached into a zone.

How is this restriction configured? with the blocks options for both the
template and the zones.

* The `blocks` option for template defines blocks that are allowed in all the
zones of a template.
* The `blocks` option for a zone defines blocks allowed in just one zone.

This means that the list of blocks allowed for one zone is the sum of the blocks
globally allowed for the template and the ones explicitly allowed for the zone.

If this sum is empty then we assume there's no restriction and every layout is
allowed.

### Attaching a template to a model

Imagine you want to set up templates to be used in your model (e.g. a Page
model). You will need a `template` attribute in your model to store which
template is assigned.

You can add this attribute by using the standard migration generator from Rails
or use the `nocms:blocks:template_migration` generator which will receive the
name of your model and generate the template migration automatically.

After generating the migration you must include the
`NoCms::Blocks::Concerns::ModelWithTemplate` concern in your model.

```
class Page

  include NoCms::Blocks::Concerns::ModelWithTemplate

end
```

This will give you the `template_config` and `template_zones` methods that will
give you access to the configuration for the selected template.

And you will have an easy way to access to the slots or blocks (depending if
you're using `NoCms::Blocks::BlockSlot` or just if you're using
`NoCms::Blocks::Block`) for a zone:

```
page.block_slots.for_template_zone(:header)
page.blocks.for_template_zone(:header)
```

You can now iterate through this blocks or slots and use the [render
helpers](./render.md) to fill yout zones in your Rails template.

### Model restrictions

The blocks can be used in several models in your app (e.g. you may have Page and
Product models and you want blocks to be attached to both models).

You can use the `models` option in the template configuration to restrict a
template to be used only in a some models. If no model option is set or it's
blank then we assume there's no restriction.
