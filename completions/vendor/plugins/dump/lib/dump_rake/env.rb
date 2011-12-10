# encoding: utf-8
class DumpRake
  module Env
    @dictionary = {
      :like => %w(LIKE VER VERSION),
      :desc => %w(DESC DESCRIPTION),
      :tags => %w(TAGS TAG),
      :leave => %w(LEAVE),
      :summary => %w(SUMMARY),
      :assets => %w(ASSETS),
      :tables => %w(TABLES),
      :backup => %w(BACKUP AUTOBACKUP AUTO_BACKUP),
      :transfer_via => %w(TRANSFER_VIA),
      :show_size => %w(SHOW_SIZE),
      :migrate_down => %w(MIGRATE_DOWN),
    }.freeze

    def self.dictionary
      @dictionary
    end

    def self.with_env(hash)
      old = {}
      hash.each do |key, value|
        key = dictionary[key].first if dictionary[key]
        old[key] = ENV[key]
        ENV[key] = value
      end
      begin
        yield
      ensure
        old.each do |key, value|
          ENV[key] = value
        end
      end
    end

    def self.with_clean_env(hash = {}, &block)
      empty_env = {}
      dictionary.keys.each{ |key| empty_env[key] = nil }
      with_env(empty_env.merge(hash), &block)
    end

    def self.[](key)
      if dictionary[key]
        ENV.values_at(*dictionary[key]).compact.first
      else
        ENV[key]
      end
    end

    def self.variable_names_for_command(command)
      mapping = {
        :create => [:desc, :tags, :assets, :tables],
        :restore => [:like, :tags, :migrate_down],
        :versions => [:like, :tags, :summary],
        :cleanup => [:like, :tags, :leave],
        :assets => [:assets],
      }
      mapping[:transfer] = [:transfer_via] + mapping[:restore]
      mapping[:mirror] = [:backup] + mapping[:create]
      mapping[:backup] = [:transfer_via] + mapping[:create]

      mapping[command] || []
    end

    def self.for_command(command, strings = false)
      variables = variable_names_for_command(command)
      variables.inject({}) do |env, variable|
        value = self[variable]
        env[strings ? dictionary[variable].first : variable] = value if value
        env
      end
    end

    def self.stringify!(hash)
      hash.keys.each do |key|
        hash[dictionary[key] ? dictionary[key].first : key.to_s] = hash.delete(key)
      end
    end

    @explanations = {
      :like => 'filter dumps by full dump name',
      :desc => 'free form description of dump',
      :tags => 'comma separated list of tags',
      :leave => 'number of dumps to leave',
      :summary => 'output info about dump',
      :assets => 'comma or colon separated list of paths or globs to dump',
      :tables => 'comma separated list of tables to dump or if prefixed by "-" — to skip; by default only sessions table is skipped; schema_info and schema_migrations are always included if they are present',
      :backup => 'no autobackup if you pass 0 or something starting with "n" or "f"',
      :transfer_via => 'transfer method (rsync, sftp or scp)',
      :migrate_down => 'don\'t run down for migrations not present in dumpif you pass 0 or something starting with "n" or "f"',
    }.freeze

    def self.explain_variables_for_command(command)
      ".\n" <<
      variable_names_for_command(command).map do |variable_name|
        "  #{dictionary[variable_name].join(', ')} — #{@explanations[variable_name]}\n"
      end.join('')
    end
  end
end
