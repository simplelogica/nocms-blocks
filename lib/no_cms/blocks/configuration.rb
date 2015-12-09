module NoCms
  module Blocks
    include ActiveSupport::Configurable

    config_accessor :block_layouts
    config_accessor :cache_enabled
    config_accessor :templates
    config_accessor :front_partials_folder
    config_accessor :admin_partials_folder
    config_accessor :serializers
    config_accessor :default_serializer

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

    self.front_partials_folder = 'no_cms/blocks/blocks'
    self.admin_partials_folder = 'no_cms/admin/blocks/blocks'

    self.serializers = {
      "DateTime" => "NoCms::Blocks::DateSerializer",
      "Date" => "NoCms::Blocks::DateSerializer",
      "Time" => "NoCms::Blocks::DateSerializer",
      "ActiveRecord::Base" => "NoCms::Blocks::ActiveRecordSerializer",
      "ActiveResource::Base" => "NoCms::Blocks::ActiveResourceSerializer"
    }

    self.default_serializer = "NoCms::Blocks::SimpleFieldSerializer"

    def self.templates_config
      @templates_config ||= NoCms::Blocks.templates.map do |template_name, template_config|
        NoCms::Blocks::Template.new template_name, template_config
      end
    end

    def self.installed_db_gem
      installed_db_gem  = ['mysql2', 'pg'].detect do |db_gem|
        begin
          Gem::Specification.find_by_name(db_gem)
        rescue Gem::LoadError
          false
        rescue
          Gem.available?(db_gem)
        end
      end

      raise 'Neither mysql2 nor pg gems have been detected' unless installed_db_gem

      installed_db_gem

    end

  end
end
