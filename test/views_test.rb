require 'test_helper'

class ViewsTest < ActiveSupport::TestCase
	def setup
	  
    MigrationTest.create_view 'active_users' do |v|
      v.select 'u.id','u.login'
      v.from 'users as u'
      v.conditions 'is_active'=>'true'
    end	  
	end
	  

  test "create view" do
    
    def_expected = %{SELECT u.id, u.login FROM users u WHERE (u.is_active = true);}
    def_created = ActiveRecord::Base.connection.select_value("select definition from pg_views where viewname='active_users'")
    assert_equal def_expected, def_created 
    MigrationTest.drop_views 'active_users'
  end

  test "add column to view" do
    
    MigrationTest.update_view 'active_users', :add, 'u.email', :dependent_views=>[:active_test_users]
    def_expected = %{SELECT u.id, u.login, u.email FROM users u WHERE (u.is_active = true);}
    def_created = ActiveRecord::Base.connection.select_value("select definition from pg_views where viewname='active_users'")
    assert_equal def_expected, def_created 
    MigrationTest.drop_views 'active_users'
  end
  test "remove column to view" do
    
    MigrationTest.update_view 'active_users', :remove, 'u.login', :dependent_views=>[:active_test_users]
    def_expected = %{SELECT u.id FROM users u WHERE (u.is_active = true);}
    def_created = ActiveRecord::Base.connection.select_value("select definition from pg_views where viewname='active_users'")
    assert_equal def_expected, def_created 
    MigrationTest.drop_views 'active_users'
  end
  test "replace columns" do
    
    MigrationTest.update_view 'active_users', :replace, 'u.login,u.email', :dependent_views=>[:active_test_users]
    def_expected = %{SELECT u.login, u.email FROM users u WHERE (u.is_active = true);}
    def_created = ActiveRecord::Base.connection.select_value("select definition from pg_views where viewname='active_users'")
    assert_equal def_expected, def_created 
    MigrationTest.drop_views 'active_users'
  end
  
  test "drop dependent views" do
    MigrationTest.create_view 'active_test_users' do |v|
      v.select '*'
      v.from 'active_users'
      v.conditions "active_users.login like '%test%'"
    end	  
    MigrationTest.drop_views 'active_users', :dependent_views=>[:active_test_users]
    count_active_test_users = ActiveRecord::Base.connection.select_value("select count(1) from pg_views where viewname='active_test_users'")
    assert_equal 0, count_active_test_users.to_i
    count_active_users = ActiveRecord::Base.connection.select_value("select count(1) from pg_views where viewname='active_users'")
    assert_equal 0, count_active_users.to_i
  end
end
