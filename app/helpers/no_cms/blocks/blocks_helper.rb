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
        #check if block is lazy
        #Si no tenemos el atributo lazy block  en la configuración de bloqueslanza excepción
        ##Solo los bloques padre serán los que se muestren como bloques lazy
        options[:lazy_block] = (!options[:lazy_block].nil? ? options[:lazy_block] : block_slot.template_zone_config.
                                config[:lazy_blocks].
                                include?(block_slot.block.template) rescue false) if block_slot.depth == 0

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

    end
  end
end
