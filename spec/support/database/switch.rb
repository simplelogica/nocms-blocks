def database_switch database
  `rm spec/dummy/config/database.yml`
  `ln -s database.#{database}.yml spec/dummy/config/database.yml`
end
