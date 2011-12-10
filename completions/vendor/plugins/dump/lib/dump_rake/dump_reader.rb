class DumpRake
  class DumpReader < Dump
    attr_reader :stream, :config

    def self.restore(path)
      new(path).open do |dump|
        ActiveRecord::Base.logger.silence do
          dump.read_config
          dump.migrate_down
          dump.read_schema

          dump.read_tables
          dump.read_assets
        end
      end
    end

    class Summary
      attr_reader :text
      alias_method :to_s, :text
      def initialize
        @text = ''
      end

      def header(header)
        @text << "  #{header}:\n"
      end

      def data(entries)
        entries.each do |entry|
          @text << "    #{entry}\n"
        end
      end

      # from ActionView::Helpers::TextHelper
      def self.pluralize(count, singular)
        "#{count} #{count == 1 ? singular : singular.pluralize}"
      end
    end

    def self.summary(path, options = {})
      new(path).open do |dump|
        dump.read_config

        sum = Summary.new

        tables = dump.config[:tables]
        sum.header 'Tables'
        sum.data tables.sort.map{ |(table, rows)|
          "#{table}: #{Summary.pluralize(rows, 'row')}"
        }

        assets = dump.config[:assets]
        sum.header 'Assets'
        sum.data assets.sort.map{ |entry|
          if String === entry
            entry
          else
            asset, paths = entry
            if Hash === paths
              "#{asset}: #{Summary.pluralize paths[:files], 'file'} (#{Summary.pluralize paths[:total], 'entry'} total)"
            else
              "#{asset}: #{Summary.pluralize paths, 'entry'}"
            end
          end
        }

        if options[:schema]
          sum.header 'Schema'
          sum.data dump.schema.split("\n")
        end

        sum
      end
    end

    def open
      Zlib::GzipReader.open(path) do |gzip|
        Archive::Tar::Minitar.open(gzip, 'r') do |stream|
          @stream = stream
          yield(self)
        end
      end
    end

    def find_entry(matcher)
      stream.each do |entry|
        if matcher === entry.full_name
          # we can not return entry - after exiting stream.each the entry will be invalid and will read from tar start
          return yield(entry)
        end
      end
    end

    def read_entry(matcher)
      find_entry(matcher) do |entry|
        return entry.read
      end
    end

    def read_entry_to_file(matcher)
      find_entry(matcher) do |entry|
        Tempfile.open('dumper') do |temp|
          temp.write(entry.read(4096)) until entry.eof?
          temp.rewind
          yield(temp)
        end
      end
    end

    def read_config
      @config = Marshal.load(read_entry('config'))
    end

    def migrate_down
      if migrate_down?
        find_entry("schema_migrations.dump") do |entry|
          migrated = table_rows('schema_migrations').map{ |row| row['version'] }

          dump_migrations = []
          Marshal.load(entry) # skip header
          dump_migrations << Marshal.load(entry).first until entry.eof?

          migrate_down = (migrated - dump_migrations)

          unless migrate_down.empty?
            migrate_down.with_progress('Migrating down').reverse.each do |version|
              DumpRake::Env.with_env('VERSION' => version) do
                Rake::Task['db:migrate:down'].tap do |task|
                  begin
                    task.invoke
                  rescue ActiveRecord::IrreversibleMigration
                    STDERR.puts "Irreversible migration: #{version}"
                  end
                  task.reenable
                end
              end
            end
          end
        end
      end
    end

    def migrate_down?
      !%w(0 n f).include?((DumpRake::Env[:migrate_down] || '').downcase.strip[0, 1])
    end

    def read_schema
      read_entry_to_file('schema.rb') do |f|
        DumpRake::Env.with_env('SCHEMA' => f.path) do
          Rake::Task['db:schema:load'].invoke
        end
        Rake::Task['db:schema:dump'].invoke
      end
    end

    def schema
      read_entry('schema.rb')
    end

    def read_tables
      verify_connection
      config[:tables].each_with_progress('Tables') do |table, rows|
        read_table(table, rows)
      end
    end

    def read_table(table, rows_count)
      find_entry("#{table}.dump") do |entry|
        table_sql = quote_table_name(table)
        clear_table(table_sql) if schema_tables.include?(table)

        columns = Marshal.load(entry)
        columns_sql = columns_insert_sql(columns)
        Progress.start(table, rows_count) do
          until entry.eof?
            rows_sql = []
            1000.times do
              rows_sql << values_insert_sql(Marshal.load(entry)) unless entry.eof?
            end

            begin
              insert_into_table(table_sql, columns_sql, rows_sql)
              Progress.step(rows_sql.length)
            rescue
              rows_sql.each do |row_sql|
                insert_into_table(table_sql, columns_sql, row_sql)
                Progress.step
              end
            end
          end
        end
      end
    end

    def read_assets
      unless config[:assets].blank?
        assets = config[:assets]
        if Hash === assets
          assets_count = assets.values.sum{ |value| Hash === value ? value[:total] : value }
          assets_paths = assets.keys
        else
          assets_count, assets_paths = nil, assets
        end

        DumpRake::Env.with_env(:assets => assets_paths.join(':')) do
          Rake::Task['assets:delete'].invoke
        end

        Progress.start('Assets', assets_count || 1) do
          catch :assets do
            # old style — in separate tar
            find_entry('assets.tar') do |assets_tar|
              def assets_tar.rewind
                # rewind will fail - it must go to center of gzip
                # also we don't need it - this is last step in dump restore
              end
              Archive::Tar::Minitar.open(assets_tar) do |inp|
                inp.each do |entry|
                  inp.extract_entry(RAILS_ROOT, entry)
                  Progress.step if assets_count
                end
              end
              throw :assets
            end

            # new style — in same tar
            assets_root_link do |tmpdir, prefix|
              stream.each do |entry|
                if entry.full_name.starts_with?("#{prefix}/")
                  stream.extract_entry(tmpdir, entry)
                  Progress.step if assets_count
                end
              end
            end
          end
        end
      end
    end
  end
end
