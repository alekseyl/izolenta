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


class User < ActiveRecord::Base; end


