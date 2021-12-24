module Izolenta::ActiveRecordMigration
  # options:
  #   wrapper_function: 'some_func' # some_func should be defined prior
  def delegate_uniqueness(origin_table, column, options = {})
    helper_table_name = "#{column}_#{origin_table}_uniqs"

    reversible do |dir|
      dir.up {
        Helpers.create_helper_table(helper_table_name, column, Helpers.get_new_column_type(origin_table, column, options))
        add_index( helper_table_name, column, unique: true )

        Helpers.create_sync_trigger( origin_table, column, helper_table_name, options )
      }

      dir.down {
        drop_table( helper_table_name )
        Helpers.drop_sync_trigger( origin_table, column )
      }
    end
  end

  module Helpers
    class << self
      def create_helper_table(helper_table, column_name, column_type )
        ActiveRecord::Base.connection.execute "CREATE TABLE #{helper_table} ( #{column_name} #{column_type} );"
      end

      def create_sync_trigger(table, column_name, helper_table_name, options )
        trg_name = "#{table}_#{column_name}_trg"
        insert_value = options[:wrapper_function] ? "#{options[:wrapper_function]}(NEW.#{column_name})"
          : "NEW.#{column_name}"
        ActiveRecord::Base.connection.execute <<~SYNC_TRIGGER
          CREATE OR REPLACE FUNCTION #{trg_name}() RETURNS trigger AS $$
          BEGIN 
            INSERT INTO #{helper_table_name} VALUES ( #{insert_value} );
            RETURN NEW;
          END $$ LANGUAGE plpgSQL;
  
          CREATE OR REPLACE TRIGGER #{trg_name} BEFORE INSERT ON #{table} FOR EACH ROW
          EXECUTE FUNCTION #{trg_name}();
        SYNC_TRIGGER
      end

      def drop_sync_trigger(table, column_name)
        trg_name = "#{table}_#{column_name}_trg"

        ActiveRecord::Base.connection.execute <<~SYNC_TRIGGER
       DROP TRIGGER IF EXISTS #{trg_name} ON #{table};
        SYNC_TRIGGER
      end

      def get_new_column_type(origin_table, column, wrapper_function: nil)
        wrapper_function ? get_function_type(wrapper_function) : get_column_type(origin_table, column)
      end

      def get_column_type(origin_table, column)
        ActiveRecord::Base.connection.schema_cache.columns_hash(origin_table.to_s)[column.to_s]&.sql_type
      end

      def get_function_type(wrapper_function)
        ActiveRecord::Base
          .connection
          .execute("SELECT typname FROM pg_type WHERE oid=(SELECT prorettype FROM pg_proc WHERE proname ='#{wrapper_function}')")
          .first['typname']
      end
    end
  end

end if defined? ActiveRecord

ActiveRecord::Migration.include(Izolenta::ActiveRecordMigration) if defined? ActiveRecord