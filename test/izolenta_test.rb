require "test_helper"
require "active_support/all"


class MigrationWithDelegatedUniqueness < ActiveRecord::Migration[4.2]
  def change
    delegate_uniqueness( :users, :email )
  end
end

# ActiveRecord::Base.logger = Logger.new(STDOUT)
#
# ActiveSupport::TestCase.

class IzolentaTest < ActiveSupport::TestCase
  include ActiveRecord::TestFixtures

  test 'helper table will be created' do
    assert_equal( ActiveRecord::Base.connection.tables, ['users'] )
    MigrationWithDelegatedUniqueness.new.migrate(:up)
    ActiveRecord::Base.connection.schema_cache.clear!
    assert_equal( ActiveRecord::Base.connection.tables.sort, %w[users email_users_uniqs].sort )
  end

  test 'User unique constraint will be introduced and work as expected' do
    MigrationWithDelegatedUniqueness.new.migrate(:up)
    assert_difference( -> {User.count} ) { User.create!(email: 'test') }
    assert_raise( ActiveRecord::RecordNotUnique ) { User.create!(email: 'test')  }
  end

  test 'User unique constraint is not exists on the schema by default' do
    assert_difference( -> {User.count} ) { User.create!(email: 'test') }
    assert_difference( -> {User.count} ) { User.create!(email: 'test') }

    assert_equal( User.pluck(:email), %w[test test] )
  end

end
