class NoCms::Blocks::SkeletonMigrationGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)


  def generate_migration
    generate "migration", "AddSkeletonTo#{class_name} skeleton:string:null"
  end

  def self.namespace
    "nocms:blocks:skeleton_migration"
  end

end
