require 'active_record'
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Migration.create_table(:users) do |t|
  t.string :email
end

class User < ActiveRecord::Base; end


