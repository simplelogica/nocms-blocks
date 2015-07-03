NoCms::Blocks.configure do |config|

  config.block_layouts['<%= name %>'] = {
    template: '<%= name %>', # This is the template of this block,
                                    # used as a partial both in the front
                                    # and the admin (if you use the nocms-admin gem)
    fields: { # This is the list of fields a block with this layout would have
      text: :string,
  #   long_text: :text,
  #   image: Image, # You may use another ActiveRecord classes of your own
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
