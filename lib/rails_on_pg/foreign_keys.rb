module RailsOnPg
  module ForeignKeys
  
    # Define new foreign key
    # Example:
    #   add_foreign_key :order_items,:product_id,:orders
    # where orders is orders is referenced table and order_items is referencing table
    # foreign key will be: 'fk_order_items_product_id'
    # optional options: 
    #   <tt>:on_delete</tt>
    #   <tt>:on_update</tt>
    #   <tt>:column</tt>
    def add_foreign_key(from_table, from_column, to_table, options={})
      # default delete and on update actions
      options.reverse_merge!({:on_delete=>'NO ACTION', :on_update=>'NO ACTION',:column=>'id'})
      constraint_name = "fk_#{from_table}_#{from_column}"

      execute %{ALTER TABLE #{from_table}
                ADD CONSTRAINT #{constraint_name}
                FOREIGN KEY (#{from_column})
                REFERENCES #{to_table}(#{options[:column]}) 
                ON UPDATE #{options[:on_update]} 
                ON DELETE #{options[:on_delete]} }
    end
  
    # Remove prev created key
    def remove_foreign_key(from_table, from_column, to_table)
      constraint_name = "fk_#{from_table}_#{from_column}"
      # check if constraint already exist
      count = ActiveRecord::Base.connection.select_value("select count(1) from pg_constraint where conname='#{constraint_name}'")

      unless count.to_i == 0
        execute %{ALTER TABLE #{from_table} DROP CONSTRAINT #{constraint_name}}
      end
    end
  
  end
end