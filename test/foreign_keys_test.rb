require 'test_helper'



class ForeignKeysTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "should create new foreign key" do
    MigrationTest.remove_foreign_key :projects, :user_id, :users
    MigrationTest.add_foreign_key :projects, :user_id, :users
    fk_name = 'fk_projects_user_id'
    count = ActiveRecord::Base.connection.select_value("select count(1) from pg_constraint where conname='#{fk_name}'")
    assert_equal 1, count.to_i
  end
end
