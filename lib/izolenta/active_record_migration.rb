module Izolenta::ActiveRecordMigration

  def delegate_uniqueness(origin_table, column, options = {})
    helper_table_name = "#{column}_#{origin_table}_uniqs"
    reversible do |dir|
      dir.up {
        create_helper_table(helper_table_name, column, get_column_type(origin_table, column ) )
        create_sync_trigger( origin_table, column, helper_table_name )
      }

      dir.down {
        drop_table( helper_table_name )
        drop_sync_trigger( origin_table, column )
      }
    end
  end

  def create_helper_table(helper_table, column_name, column_type )
    ActiveRecord::Base.connection.execute <<~CREATE_TABLE
      CREATE TABLE #{helper_table} ( #{column_name} #{column_type} );
    CREATE_TABLE

    add_index( helper_table, column_name, unique: true )
  end

  def create_sync_trigger(table, column_name, helper_table_name)
    trg_name = "#{table}_#{column_name}_trg"
    ActiveRecord::Base.connection.execute <<~SYNC_TRIGGER
       CREATE OR REPLACE FUNCTION #{trg_name}() RETURNS trigger AS $$
       BEGIN 
         INSERT INTO #{helper_table_name} VALUES ( NEW.#{column_name} );
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

  def get_column_type(origin_table, column)
    ActiveRecord::Base.connection.schema_cache.columns_hash(origin_table.to_s)[column.to_s]&.sql_type
  end

end if defined? ActiveRecord

ActiveRecord::Migration.include(Izolenta::ActiveRecordMigration) if defined? ActiveRecord