require 'active_record'
require 'pg'

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: 'izolenta-test',
  user: 'postgres'
)

ActiveRecord::Migration.create_table(:users, force: true) do |t|
  t.string :email
  t.boolean :force_uniq
end

ActiveRecord::Migration.create_table(:dialogs, force: true, options: 'WITH (fillfactor=70)') do |t|
  t.bigint :user_ids, array: true
end

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