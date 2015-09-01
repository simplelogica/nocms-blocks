module NoCms
  module Blocks
    module BlocksHelper

      ##
      # This method just delegates in the render_block helper appending some
      # info about the block_slot to the cache_key. This way, the block will
      # have a context dependant cache in case the block depends on some info of
      # the object container of the slot.
      def render_block_slot block_slot, options= {}
        return '' if block_slot.block.nil?

        # if the initial_cache_key param is blank we use the blockslot cache
        # key. Othwersise we combine the blockslot cache key with the param
        options[:initial_cache_key] = options[:initial_cache_key].blank? ?
          block_slot.cache_key :
          "#{block_slot.cache_key}/#{options[:initial_cache_key]}"

        render_block block_slot.block, options
      end

      def render_block block, options = {}
        return if block.draft && !options[:force_render_draft]
        # If we don't have any option about cache enabled then we ask the block
        options[:cache_enabled] = block.cache_enabled unless options.has_key? :cache_enabled

        block_template = "no_cms/blocks/blocks/#{block.template}"

        # And now decide if we use cache or not
        if options[:cache_enabled]
          Rails.cache.fetch cache_key_for_blocks(block, block_template, options) do
            render block_template, block: block
          end
        else
          render block_template, block: block
        end

      end

      def cache_key_for_blocks block, block_template, options = {}
        "#{block_template}/#{block.id}/#{block.updated_at.to_i}#{"/#{options[:initial_cache_key]}" if options[:initial_cache_key] }"
      end

    end
  end
end
