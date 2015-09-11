class TemplateGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  class_option :zones,
    :type => :string,
    :default => "header,body,footer",
    :description => "Comma separated names of the zones of the template. On each zone you can set the name of the zones."

  class_option :layouts,
    :type => :string,
    :default => "",
    :description => "Comma separated names of the layouts globally allowed in the template"

  class_option :models,
    :type => :string,
    :default => "",
    :description => "Comma separated names of the models restricted to this template"

  def parse_options

    @zones = {}
    options.zones.split(',').each do |zone_info|
      zone_name, layout_names = zone_info.gsub('}','').split('{')
      @zones[zone_name] = layout_names.blank? ? [] : layout_names.split(':')
    end

    @layouts = options.layouts.split(',')

    @models = options.models.split(',')

  end

  def generate_template_initializer
    template "initializers/template.erb",
      File.join(destination_root, "config/initializers/nocms/blocks/templates/#{file_name}.rb")
  end

  def self.namespace
    "nocms:blocks:template"
  end

end
