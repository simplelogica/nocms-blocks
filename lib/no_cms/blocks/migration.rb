module NoCms
  module Blocks
    # Rails 6 demands not inheriting from ActiveRecord::Migration without specifying
    # the ActiveRecord version the migration was generated in (e.g ActiveRecord::Migration[4.2])
    # This is incompatible with Rails 4 applications that doesn't know how to handle
    # it, so we have to check the Rails Version.
    Migration = if ActiveRecord::VERSION::MAJOR.to_i >= 5
      ActiveRecord::Migration[NoCms::Blocks.active_record_version_for_migration]
    else
      ActiveRecord::Migration
    end
  end
end
