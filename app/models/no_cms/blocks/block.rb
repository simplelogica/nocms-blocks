module NoCms::Blocks
  class Block < ActiveRecord::Base

    include  NoCms::Blocks::Concerns::TranslationScopes

    acts_as_nested_set

    has_many :slots, class_name: "NoCms::Blocks::BlockSlot", dependent: :destroy

    scope :drafts, ->() { where_with_locale(draft: true) }
    scope :no_drafts, ->() { where_with_locale(draft: false) }
    scope :roots, ->() { where parent_id: nil }
    scope :for_template_zone, -> (template_zone) { where(template_zone: template_zone).order(position: :asc) }

    translates :draft
    include  NoCms::Blocks::Concerns::SerializingFields

    after_save :touch_slots

    ##
    # In the block we get all the fields so it can accept all of them
    def fields_configuration
      layout_config.fields
    end

    ##
    # Get CSS files relative path for the current block
    def css_files
      css_templates = layout_config.css_templates || []
      css_templates.map do |css_template|
        media_type = css_template.split("_").last.to_sym
        media_query = NoCms::Blocks.css_mediaqueries[media_type]
        ["#{NoCms::Blocks.css_blocks_folder}/#{self.layout}/#{css_template}", media_query]
      end
    end


    validates :layout, presence: true
    validate :validate_block_layout

    ##
    # A block dups all it's children and the translations
    def duplicate_self new_self

      new_self.translations = translations.map(&:dup)
      new_self.translations.each { |t| t.globalized_model = new_self }

      children.each do |child|
        new_self.children << child.dup
      end
    end

    class Translation

      ##
      # In the translation we get only the translated fields
      def fields_configuration
        layout_config.translated_fields
      end

      ##
      # Sometimes the translation still won't have the globalized_model linked
      # (e.g. before it's saved for the first time) and we must have a mechanism
      # to be able to store a temporary layout
      attr_accessor :layout

      ##
      # If we don't have a globalized model yet we return our temporary layout
      def layout
        # Since respond_to_missing? has been reimplemented in
        # NoCms::Blocks::Concerns::SerializingFields we need to first check that
        # we have the foreign key to access the globalized_model association
        #
        # This is due to the empty translations Globalize creates sometimes that
        # only have locale.
        #
        # If we don't check then we will throw a non defined attribute
        # exception.

        # First we check wether we don't respond to the foreign key of the
        # globalize model association
        if !respond_to?(self.class.reflections.symbolize_keys[:globalized_model].foreign_key) ||
          globalized_model.nil? # and then that the globalized model is nil

          # In any of these cases we return our stored layout
          @layout
        else
          # If we can access to the globalized_model, then we return its
          # information
          globalized_model.layout
        end
      end

      include  NoCms::Blocks::Concerns::SerializingFields
    end

    accepts_nested_attributes_for :children, allow_destroy: true
    accepts_nested_attributes_for :translations

    ##
    # If the block has slots and the layout has changed we check that the layout
    # restrictions from the templates are satisfied
    def validate_block_layout
      if layout_changed?
        if slots.detect{|s| !s.block_layout_belongs_to_template? }
          errors.add(:layout, :invalid)
        end
      end
    end
    private :validate_block_layout

    ##
    # Method that will define wich partial is used in the public views. It uses
    # the engine configuration to read the partials folder and then add the
    # block template
    def to_partial_path
      "#{NoCms::Blocks.front_partials_folder}/#{self.template}"
    end

    ##
    # Method that will define wich partial is used for the block in the admin
    # views. It uses the engine configuration to read the partials folder and
    # then add the block template
    def to_admin_partial_path
      "#{NoCms::Blocks.admin_partials_folder}/#{self.template}"
    end


    ##
    # Method that will define skeleton path in the public views
    # It uses the engine configuration to read the partials folder and
    # then add the skeleton template
    def to_skeleton_path
      "#{NoCms::Blocks.front_skeletons_folder}/#{layout_config.skeleton_template}"
    end

    ##
    # Notifies the block slots that the block has changed.
    def touch_slots
      slots.update_all(updated_at: Time.now)
    end
    private :touch_slots
  end

end
