require 'active_record'
require 'pg'

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: 'izolenta-test',
  user: 'postgres'
)

ActiveRecord::Migration.create_table(:users) do |t|
  t.string :email
end unless ActiveRecord::Base.connection.data_source_exists? :users

ActiveRecord::Migration.create_table(:dialogs) do |t|
  t.bigint :user_ids, array: true
end unless ActiveRecord::Base.connection.data_source_exists? :dialogs


class User < ActiveRecord::Base; end

class Dialog < ActiveRecord::Base;
  WRAPPER_FUNCTION = <<~ARRAY_TO_S
    CREATE OR REPLACE FUNCTION user_ids_to_str( user_ids anyarray ) RETURNS text AS $$
     BEGIN
          RETURN CASE WHEN( user_ids[1] > user_ids[2]) 
            THEN user_ids[1]::text || '_' || user_ids[2]::text 
            ELSE user_ids[2]::text || '_' || user_ids[1]::text END;
      END
    $$ LANGUAGE plpgSQL;
  ARRAY_TO_S
end

ActiveRecord::Base.connection.execute Dialog::WRAPPER_FUNCTION