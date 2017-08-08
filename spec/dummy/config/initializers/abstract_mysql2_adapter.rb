# With new mysql versions and old rails versions we need this to avoid the
# "Mysql::Error: All parts of a PRIMARY KEY must be NOT NULL; if you need NULL
# in a key, use UNIQUE instead" error. More info at
# https://github.com/rails/rails/pull/13247#issuecomment-32425844
if NoCms::Blocks.installed_db_gem == "mysql2"
  class ActiveRecord::ConnectionAdapters::Mysql2Adapter
    NATIVE_DATABASE_TYPES[:primary_key] = "int(11) auto_increment PRIMARY KEY"
  end
end
