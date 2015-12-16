NoCms::Blocks.configure do |config|

  # Enable Rails fragment cache for the block templates when you call the render_block helper
  # You can override this cache setting in any block configuration below or sending
  # the cache option true or false when calling the block helpers
  # e.g: render_block block, cache: true
  # config.cache_enabled = false

  # Option used in the blocks model for serializing all the fields info.
  #
  # Exceppt when :hstore is set, it will be used as the second option in the
  # serialize method from Active Record as seen in
  # http://api.rubyonrails.org/classes/ActiveRecord/AttributeMethods/Serialization/ClassMethods.html#method-i-serialize
  #
  # Right now, Hash, JSON and :hstore are the only valid options with hash as
  # the default value.
  # config.database_serializer = Hash

  # Route inside your app/views/ folder where the block partial files will be
  # located.
  # By default the no_cms/blocks/blocks folder will be used, but you can
  # customize it to fix better in your views structure (e.g: my_app/blocks)
  # config.front_partials_folder = 'no_cms/blocks/blocks'

  # Route inside your app/views/ folder where the block partial files for
  # amdinistration will be located.
  # By default the no_cms/admin/blocks/blocks folder will be used, but you can
  # customize it to fix better in your views structure (e.g: my_app/blocks)
  # config.admin_partials_folder = 'no_cms/admin/blocks/blocks'

  # In this section we configure block layouts. It's just an array of layouts, each consisting on a hash.
  # Each layout has a series of options
  # E.g: config.block_layouts = {
  #   'title-long_text' => {
  #     template: 'title-long_text', # This is the template of this block,
  #                                  # used as a partial both in the front
  #                                  # and the admin (if you use the nocms-admin gem)
  #     fields: { # This is the list of fields a block with this layout would have
  #       title: :string,
  #       long_text: :text,
  #       image: Image, # You may use another ActiveRecord or ActiveResource classes
  #                     # of your own
  #       starts_at: Date, # You can also use Date / Time / DateTime classes
  #       column: { # You can configure the block with more options than just
  #                # the type of the field. If you use the "quick" configuration
  #                # all other settings will get the default value
  #         type: :text, # The type of the field, just as explained before
  #         translated: true # If the field must store different values for
  #                           # each translation. By default every field is
  #                           # translated
  #         duplicate: :dup, # behaviour of the field when the block is duplicated.
  #                          # It can be set to :dup (it executes the dup method),
  #                          # :nullify (it sets the field to nil) or :link (it
  #                          # uses the same exact object)
  #         multiple: false # Configures whether the field stores only one
  #                         # object or more than one.
  #     }
  #    allow_nested_blocks: true, # A block with this layout may include a list of nested blocks
  #                               # This setting is actually used by nocms-admin gem to show
  #                               # nested forms
  #    nest_levels: [0] # Some layout may not be nestable, or useful only in certain nesting level
  #                     # Once again, this setting is used by nocms-admin gem to hide certain
  #                     # in nested blocks. When blank, it's assumed there's no restriction.
  #    cache_enabled: false # When setting cache_enabled you will be **overriding** the global cache_enabled
  #                         # setting. If you don't set a cache setting then it will use the global cache
  #                         # setting specified above
  #   },
  #   'title-3_columns_text' => {
  #     template: 'title-3_columns_text',
  #     fields: {
  #       title: :string,
  #       column_1: :text,
  #       column_2: :text,
  #       column_3: :text
  #     }
  #   }
  # }
  # config.block_layouts = {}


  # In this section we configure the templates available to define collections of
  # placeholders and blocks allowed on those placeholders.
  #
  # The usual case is to have another model (e.g. Page) where you store which
  # template is enabled for the current instance and all the restrictions are
  # then automatically set up from the configuration.
  #
  # By default there's one template with three zones defined.
  # config.templates = {
  #   'default' => {
  #     blocks: nil, # These are the block layouts globally allowed in every
  #                  # zone of this template
  #     models: ["Page"],  # These are the name of the models where this
  #                        # template is appliable. If there are no models it
  #                        # means that it :Dapplies to every model with templates
  #     zones: {     # These are the defined zones
  #       header: {  # Each zone has a name, which will be used by the blocks
  #                  # and slots to store where they belong
  #         blocks: [ 'sample' ] # Blocks allowed in this zone. If it's blank
  #                              # and there are not blocks allowed in the
  #                              # template, then there will be no restriction
  #       },
  #       body: {
  #         blocks: nil
  #       },
  #       footer: {
  #         blocks: nil
  #       }
  #     }
  #   }
  # }
end
