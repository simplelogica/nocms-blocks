NoCms::Blocks.configure do |config|

  config.block_layouts['<%= name %>'] = {
    template: '<%= name %>', # This is the template of this block,
                                    # used as a partial both in the front
                                    # and the admin (if you use the nocms-admin gem)
    fields: { # This is the list of fields a block with this layout would have
      text: :string,
  #   long_text: :text,
  #   image: Image, # You may use another ActiveRecord or ActiveResource classes
  #                 # of your own
  #   starts_at: Date, # You can also use Date / Time / DateTime classes
  #   column: { # You can configure the block with more options than just
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
  #       }
    },
    allow_nested_blocks: true, # A block with this layout may include a list of nested blocks
                               # This setting is actually used by nocms-admin gem to show
                               # nested forms
    nest_levels: [0], # Some layout may not be nestable, or useful only in certain nesting level
                     # Once again, this setting is used by nocms-admin gem to hide certain
                     # in nested blocks. When blank, it's assumed there's no restriction.
    cache_enabled: false # When setting cache_enabled you will be **overriding** the global cache_enabled
                         # setting. If you don't set a cache setting then it will use the global cache
                         # setting specified above
  }

end
