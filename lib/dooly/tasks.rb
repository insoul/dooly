namespace :db do
  namespace :migrate do
    desc 'insert version to migration table directly'
    task :force, [:version] => :environment do |t, args|
      ActiveRecord::Base.connection.initialize_schema_migrations_table
      version = Integer(ENV['VERSION'] || args[:version])
      migrations = ActiveRecord::Migrator.migrations(ActiveRecord::Migrator.migrations_paths)
      table = Arel::Table.new(ActiveRecord::Migrator.schema_migrations_table_name)
      migrated = ActiveRecord::Migrator.get_all_versions

      migrations.each do |mig|
        break if mig.version > version
        next if migrated.include? mig.version

        puts "insert into #{table.name}, version #{mig.filename}"
        migrated << mig.version
        stmt = table.compile_insert table['version'] => mig.version.to_s
        ActiveRecord::Base.connection.insert stmt
      end
    end

    namespace :force do
      desc 'delete specified version from migration table directly'
      task :down, [:version] => :environment do |t, args|
        ActiveRecord::Base.connection.initialize_schema_migrations_table
        version = Integer(ENV['VERSION'] || args[:version])
        table = Arel::Table.new(ActiveRecord::Migrator.schema_migrations_table_name)

        puts "delete from #{table.name}, version #{version}"
        stmt = table.where(table['version'].eq(version)).compile_delete
        ActiveRecord::Base.connection.delete stmt
      end
    end
  end
end
