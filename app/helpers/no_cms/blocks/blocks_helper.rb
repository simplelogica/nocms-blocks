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

        # We include the slot in the locals option
        options[:locals] ||= {}
        options[:locals][:slot] = block_slot
        # The block slot must set wether the block is lazy, as it's a conriguration of the zone
        # If we receive a lazy block option it overwrites the zone configuration
        unless options.has_key?(:lazy_block) ||
          block_slot.depth != 0 # If it's a child block it won't be lazy either

          options[:lazy_block] = block_slot.template_zone_config.is_lazy_layout?(block_slot.block.layout)
        end

        render_block block_slot.block, options
      end

      def render_block block, options = {}
        return if block.draft && !options[:force_render_draft]
        # If we don't have any option about cache enabled then we ask the block
        options[:cache_enabled] = block.cache_enabled unless options.has_key? :cache_enabled
        block_template = options[:lazy_block] ? block.to_skeleton_path : block.to_partial_path
        options[:template_layout] = (block.layout_config.config[:template_layout] || "block" rescue "block")

        # We search for the partial. In order to set default if render do not exists
        unless lookup_context.exists?("/layouts/no_cms/blocks/_#{options[:template_layout]}")
          options[:template_layout] = "block"
        end

        locals = options[:locals] || {}
        locals[:block] = block
        # And now decide if we use cache or not
        if options[:cache_enabled]
          Rails.cache.fetch cache_key_for_blocks(block, block_template, options) do
            render partial: block_template, layout: "/layouts/no_cms/blocks/#{options[:template_layout]}", locals: locals
          end
        else
          render partial: block_template, layout: "/layouts/no_cms/blocks/#{options[:template_layout]}", locals: locals
        end

      end

      def cache_key_for_blocks block, block_template, options = {}
        "#{options[:template_layout]}/#{block_template}/#{block.id}/#{block.updated_at.to_i}#{"/#{options[:initial_cache_key]}" if options[:initial_cache_key] }"
      end

      ##
      # This helper returns the stylesheet link tags for each css templates configured for the block
      def stylesheet_link_tags_for_block block, options = {}
        stylesheet_link_tags = block.css_files.map do |css_file, css_media|
          stylesheet_link_tag(css_file, options.merge(media: css_media))
        end.join('')

        raw stylesheet_link_tags
      end
    end
  end
end
