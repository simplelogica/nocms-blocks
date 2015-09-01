module NoCms
  module Blocks
    module BlocksHelper
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
