class NoCms::Blocks::TemplateMigrationGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)


  def generate_migration
    generate "migration", "AddTemplateTo#{name} template:string:null"
  end

  def self.namespace
    "nocms:blocks:template_migration"
  end

end
