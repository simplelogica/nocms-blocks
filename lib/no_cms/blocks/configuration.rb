module NoCms
  module Blocks
    include ActiveSupport::Configurable

    config_accessor :block_layouts
    config_accessor :cache_enabled
    config_accessor :templates
    config_accessor :front_partials_folder
    config_accessor :front_skeletons_folder
    config_accessor :admin_partials_folder
    config_accessor :serializers
    config_accessor :default_serializer
    config_accessor :database_serializer
    config_accessor :i18n_fallbacks_enabled
    config_accessor :i18n_fallbacks
    config_accessor :i18n_fallback_on_blank

    self.templates = {
      'default' => {
        blocks: nil,
        models: [],
        zones: {
          header: {
            blocks: nil
          },
          body: {
            blocks: nil
          },
          footer: {
            blocks: nil
          }
        }
      }
    }

    self.block_layouts = {
      'default' => {
        template: 'default',
        fields: {
          title: :string,
          body: :text
        }
      }
    }
    self.cache_enabled = false

    self.front_partials_folder  = 'no_cms/blocks/blocks'
    self.front_skeletons_folder = 'no_cms/blocks/blocks/skeletons'
    self.admin_partials_folder  = 'no_cms/admin/blocks/blocks'

    self.serializers = {
      "DateTime" => "NoCms::Blocks::DateSerializer",
      "Date" => "NoCms::Blocks::DateSerializer",
      "Time" => "NoCms::Blocks::DateSerializer",
      "ActiveRecord::Base" => "NoCms::Blocks::ActiveRecordSerializer",
      "ActiveResource::Base" => "NoCms::Blocks::ActiveResourceSerializer"
    }

    self.default_serializer = "NoCms::Blocks::SimpleFieldSerializer"

    self.database_serializer = Hash

    self.i18n_fallbacks_enabled = false
    self.i18n_fallback_on_blank = false
    self.i18n_fallbacks = Globalize.fallbacks

    def self.templates_config
      @templates_config ||= NoCms::Blocks.templates.map do |template_name, template_config|
        NoCms::Blocks::Template.new template_name, template_config
      end
    end

    def self.installed_db_gem
      installed_db_gem  = ['mysql2', 'pg', 'sqlite3'].detect do |db_gem|
        begin
          Gem::Specification.find_by_name(db_gem)
        rescue Gem::LoadError
          false
        rescue
          Gem.available?(db_gem)
        end
      end

      raise 'Neither mysql2, pg nor sqlite3 gems have been detected' unless installed_db_gem

      installed_db_gem

    end

  end
end
