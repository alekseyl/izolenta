require "test_helper"
require "active_support/all"


class EmailDelegatedUniqueness < ActiveRecord::Migration[4.2]
  def change
    delegate_uniqueness( :users, :email )
  end
end

class DialogUsersUniqueness < ActiveRecord::Migration[4.2]
  def change
    delegate_uniqueness( :dialogs, :user_ids, wrapper_function: 'user_ids_to_str' )
  end
end
# ActiveRecord::Base.logger = Logger.new(STDOUT)

class IzolentaTest < ActiveSupport::TestCase
  include ActiveRecord::TestFixtures

  test 'helper table will be created' do
    assert_equal( ActiveRecord::Base.connection.tables.sort, %w[dialogs users] )
    EmailDelegatedUniqueness.new.migrate(:up)
    ActiveRecord::Base.connection.schema_cache.clear!
    assert_equal( ActiveRecord::Base.connection.tables.sort, %w[dialogs email_users_uniqs users] )
  end

  test 'User unique constraint will be introduced and work as expected' do
    EmailDelegatedUniqueness.new.migrate(:up)
    assert_difference( -> {User.count} ) { User.create!(email: 'test') }
    assert_raise( ActiveRecord::RecordNotUnique ) { User.create!(email: 'test')  }
  end

  test 'User unique constraint is not exists on the schema by default' do
    assert_difference( -> {User.count} ) { User.create!(email: 'test') }
    assert_difference( -> {User.count} ) { User.create!(email: 'test') }

    assert_equal( User.pluck(:email), %w[test test] )
  end

  test 'Dialog test wrapper_function is working as expected with wrapper_function' do
    DialogUsersUniqueness.new.migrate(:up)
    assert_difference( -> {Dialog.count} ) { Dialog.create!( user_ids: [1,2]) }

    assert_raise( ActiveRecord::RecordNotUnique ) { Dialog.create!( user_ids: [1,2])  }
    assert_raise( ActiveRecord::RecordNotUnique ) { Dialog.create!( user_ids: [2,1])  }
  end

  test 'No UNIQUENESS issue on Dialogs whenever Migration is not defined' do
    assert_difference( -> {Dialog.count} ) { Dialog.create!( user_ids: [1,2]) }
    assert_difference( -> {Dialog.count} ) { Dialog.create!( user_ids: [1,2])  }
    assert_difference( -> {Dialog.count} ) { Dialog.create!( user_ids: [2,1])  }
  end

end
