ActiveRecord::Schema.define(:version => 0) do

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", :force => true do |t|
    t.string   "value"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.text     "about"
    t.boolean  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
end
