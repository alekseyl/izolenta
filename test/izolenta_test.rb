require "test_helper"

class IzolentaTest < Minitest::Test
  extend ::ActiveSupport::Testing::Declarative
  test 'table will be created and ' do
    assert_equal( ActiveRecord::Base.connection.tables, ['users'] )
    ActiveRecord::Migration.delegate_uniqueness( :users, :email )
    assert_equal( ActiveRecord::Base.connection.tables, %w[users email_users_uniqs] )
  end
end
