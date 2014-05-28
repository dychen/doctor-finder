namespace :db do
  task :migrate do
    `sequel -m db/migrations sqlite://db/development.db`
  end
  task :drop do
    tables = DB.tables
    tables.each { |t| DB.drop_table t }
  end
end
