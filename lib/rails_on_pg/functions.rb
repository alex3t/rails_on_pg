module RailsOnPg
  module Functions
    
    # Create new plpgsql function
    # Example:
    #  create_function 'format_name', {:returns=>'character varying'}, 'first_name character varying(125)', 'middle_name character varying(15)', "last_name character varying(20)" do
    #    "RETURN COALESCE(last_name, 'no last name') || ', ' || COALESCE(first_name, 'no first name') || ' ' || COALESCE(middle_name || '.','');"
    #  end    
    def create_function name, options={}, *params
      options.reverse_merge!({:as=>'$$'})
      returns = options[:returns]
      declare = %{DECLARE 
                  #{options[:declare].join(';')}} if options[:declare]
      drop_function name, params
      # execute
      set_lang
      execute %{CREATE FUNCTION #{name}(#{params.join(',')}) RETURNS #{returns} AS #{options[:as]}
      #{declare}
      BEGIN
        #{yield}
      END;
      #{options[:as]} LANGUAGE 'plpgsql';
      }
    end
    
    # drop function   
    def drop_function name, *params
      execute "DROP FUNCTION IF EXISTS #{name}(#{params.join(',')}) CASCADE"    
    end
   
    # Create trigger function for it
    # <tt>name</tt> - trigger name
    # <tt>type</tt> - :before or :after
    # <tt>table_name</tt> - table name
    # <tt>actions</tt> - "insert","update","delete"
    # Example:
    #    create_trigger "some_tr", :before, "users", "insert","update"
    def create_trigger name, type, table_name, *actions
      create_function "#{name}_f", :returns=>'trigger',:as=>'$BODY$' do
        yield
      end
      execute %{CREATE TRIGGER #{name} #{type.to_s.upcase} #{actions.map{|str|str.upcase}.join(' OR ')}
      ON "#{table_name}" FOR EACH ROW
      EXECUTE PROCEDURE #{name}_f();}
    end
    
    # Drop trigger
    def drop_trigger name, table_name
      execute "DROP TRIGGER #{name} on #{table_name} CASCADE"    
    end
   
   private
    def set_lang lang='plpgsql'
      begin
        execute("CREATE LANGUAGE #{lang}")
      rescue ActiveRecord::StatementInvalid => ex      
      end
    end
   
    
  end
end