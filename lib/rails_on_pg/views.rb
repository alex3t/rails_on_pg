module RailsOnPg
  module Views
    
    # Create new view
    # <tt>name</tt> - name of view 
    # Example:     
    #   create_view :active_patients do |v|
    #     v.select 'p.patient_id as id' ,'p.id as visit_id'
    #     v.from 'patients as p'
    #     v.join 'left join demographics d on d.visit_id=v.id'
    #     v.join 'left join diagnoses di on di.visit_id=v.id and di.row_index=0'
    #     v.conditions 'p.status'=>'active','p.name' => 'John' #or "p.status='active' and p.name='John'"
    #   end
    # See ViewDefinition class
    def create_view name, options={}, &block      
      view_def = ViewDefinition.new name, &block
      
      drop_views name, options[:dependent_views]      
      execute view_def.to_sql
    end
    
    # Update view's select columns
    # <tt>name</tt> - name of existed view 
    # <tt>type</tt> - type of action(:add,:remove or :replace) 
    # <tt>columns</tt> - array of columns or string
    # <tt>options</tt> - options
    # Options:
    # <tt>:dependent_views</tt> - if view has dependent views(views where current view used) then you need list them here
    # Example:
    #   update_view :active_patients, :add, ['p.first_name as name','p.age as dob']
    #   update_view :active_patients, :add, 'p.first_name as name', :dependent_views=>['view0','view1']
    #   update_view :active_patients, :remove, 'p.first_name as name', :dependent_views=>['view0','view1']
    #   update_view :active_patients, :replace, ['p.first_name as name','p.age as dob'] #replace all select columns
    def update_view name, type, columns, options={}
      view_structure = ActiveRecord::Base.connection.select_value("select definition from pg_views where viewname='#{name}'")
      raise ViewNotExistException("View #{name} does not exist in current db") unless view_structure
      
      columns_str = columns.is_a?(Array) ? columns.join(',') : columns
      
      select_pattern = /select (.*) from/i
      select_str = view_structure[select_pattern,1]

      case type
        when :add
          view_structure.gsub!(select_pattern, "SELECT #{select_str}, #{columns_str} FROM")
        when :remove
          select_str.gsub!(", #{columns_str}", '')
          view_structure.gsub!(select_pattern, "SELECT #{select_str} FROM")
        when :replace
          view_structure.gsub!(select_pattern, "SELECT #{columns_str} FROM")
      end

      drop_views name, options[:dependent_views] 
      execute "CREATE VIEW #{name} AS #{view_structure};"
    end
    
    # drop dependent views before if exists
    # Options
    # <tt>:dependent_views</tt> - if view has dependent views(views where current view used) then you need list them here    
    def drop_views name, defs=nil
      defs = defs.delete(:dependent_views) if defs.is_a?(Hash)
      defs.each do |dependent_view|
        execute "DROP VIEW IF EXISTS #{dependent_view}"
      end if defs
      
      execute "DROP VIEW IF EXISTS #{name}"

    end
    
    # recreate view without changes
    def recreate_view name
      view_structure = ActiveRecord::Base.connection.select_value("select definition from pg_views where viewname='#{name}'")
      if view_structure
        execute "DROP VIEW IF EXISTS #{name}"
        execute "CREATE VIEW #{name} AS #{view_structure};"
      end
    end
    
    # ===========
    # = Classes =
    # ===========
    class ViewNotExistException < Exception; end    
    
    # View definition, see create_view dsl
    class ViewDefinition
      def initialize name, &block
        @joins = []
        @name = name
        instance_eval &block
      end
      
      def select *columns
        @select = columns.join(',')
      end
      def from *tables
        @from = tables.join(',')
      end
      def join value
        @joins << value
      end
      def conditions cond

        @where = cond.collect{ |attrib, value| "#{attrib} = #{value}"}.join(" AND ") if cond.is_a?(Hash)
        @where = cond if cond.is_a?(String)
      end

      def to_sql
        @where ||= '1=1'
        "CREATE VIEW #{@name} AS SELECT #{@select} FROM #{@from} #{@joins.join(' ')} WHERE #{@where};"
      end
    end
    
        
  end
end