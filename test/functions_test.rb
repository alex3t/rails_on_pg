require 'test_helper'

class FunctionsTest < ActiveSupport::TestCase
	def setup
	  
  
	end
	
  test "should create new function" do
    MigrationTest.create_function 'format_name', {:returns=>'character varying'}, 'first_name character varying(125)', 'middle_name character varying(15)', "last_name character varying(20)" do
      "RETURN COALESCE(last_name, 'no last name') || ', ' || COALESCE(first_name, 'no first name') || ' ' || COALESCE(middle_name || '.','');"
    end    
    f_count = ActiveRecord::Base.connection.select_value(
    "select count(1) from pg_proc where proname='format_name'")
    assert_equal 1, f_count.to_i
  end
  
  test "should succefully drop function" do
    MigrationTest.drop_function 'format_name', 'first_name character varying(125)', 'middle_name character varying(15)', "last_name character varying(20)"
    f_count = ActiveRecord::Base.connection.select_value(
    "select count(1) from pg_proc where proname='format_name'")
    assert_equal 0, f_count.to_i
  end

  test "should create new trigger" do
    MigrationTest.create_trigger "some_tr", :before, "users", "insert","update" do
      
    end
    f_count = ActiveRecord::Base.connection.select_value(
    "select count(1) from pg_trigger where tgname='some_tr'")
    assert_equal 1, f_count.to_i
  end
  
  test "should succefully drop trigger" do
    MigrationTest.drop_trigger 'some_tr','users'
    f_count = ActiveRecord::Base.connection.select_value(
    "select count(1) from pg_trigger where tgname='some_tr'")
    assert_equal 0, f_count.to_i
  end
  
	
	
end