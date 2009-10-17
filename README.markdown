# RailsOnPG

This is timesaver for middle/large Rails application which used PostgreSQL as database.
Create/drop Views, Functions, Triggers, Foreign keys in your migrations using ruby syntax.

## Installation
    script/plugin install git://github.com/alex3t/rails_on_pg.git
    
## Views

  create_view :active_patients do |view|
    view.select 'p.patient_id as id' ,'p.id as visit_id'
    view.from 'patients as p'
    view.join 'left join demographics d on d.visit_id=v.id'
    view.conditions 'p.status'=>'active','p.name' => 'John' #or "p.status='active' and p.name='John'"
  end
  
## Functions

  create_function 'format_name', {:returns=>'character varying'}, 'first_name character varying(125)', 'middle_name character varying(15)', "last_name character varying(20)" do
    "RETURN COALESCE(last_name, 'no last name') || ', ' || COALESCE(first_name, 'no first name');"
  end  
    
## Triggers  

  create_trigger "update_status", :before, "users", "insert","update"
    #update status function body here
  end
  
## Foreign keys

  add_foreign_key :order_items, :product_id, :orders, :on_delete=>""
  
####
For more details see rdoc or tests

  
## Todo
Make as gem

    
###### Copyright (c) 2009 Alex Tretyakov, released under MIT license