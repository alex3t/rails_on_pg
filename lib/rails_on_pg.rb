
require "rails_on_pg/foreign_keys"
require "rails_on_pg/views"
require "rails_on_pg/functions"

ActiveRecord::Migration.send(:extend, RailsOnPg::ForeignKeys)
ActiveRecord::Migration.send(:extend, RailsOnPg::Views)
ActiveRecord::Migration.send(:extend, RailsOnPg::Functions)


