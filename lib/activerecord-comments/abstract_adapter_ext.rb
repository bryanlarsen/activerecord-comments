module ActiveRecord::Comments::AbstractAdapterExt

  def self.included base
    base.instance_eval {
      alias_method_chain :columns, :parent # this is evil!!!  how to fix?  column needs to know its table  :(
    }
  end

  # Get the database comment (if any) defined for a table
  #
  # ==== Parameters
  # table<~to_s>::
  #   The name of the table to get the comment for
  #
  # ==== Returns
  # String:: The comment for the given table (or nil if no comment)
  #
  # :api: public
  def comment table
    adapter = adapter_name.underscore
    adapter = "mysql" if adapter=="my_sql" || adapter=="jdbc"
    database_specific_method_name = "#{ adapter }_comment"
    
    if self.respond_to? database_specific_method_name
      send database_specific_method_name, table.to_s
    else

      # try requiring 'activerecord-comments/[name-of-adapter]_adapter'
      begin

        # see if there right method exists after requiring
        require "activerecord-comments/#{ adapter }_adapter"
        if self.respond_to? database_specific_method_name
          send database_specific_method_name, table.to_s
        else
          raise ActiveRecord::Comments::UnsupportedDatabase.new("#{adapter} unsupported by ActiveRecord::Comments")
        end

      rescue LoadError
        raise ActiveRecord::Comments::UnsupportedDatabase.new("#{adapter} unsupported by ActiveRecord::Comments")
      end
    end
  end

  # Get the database comment (if any) defined for a column
  #
  # ==== Parameters
  # column<~to_s>::
  #   The name of the column to get the comment for
  #
  # table<~to_s>::
  #   The name of the table to get the column comment for
  #
  # ==== Returns
  # String:: The comment for the given column (or nil if no comment)
  #
  # :api: public
  def column_comment column, table
    adapter = adapter_name.underscore
    adapter = "mysql" if adapter=="my_sql" || adapter=="jdbc"
    database_specific_method_name = "#{ adapter }_column_comment"
    
    if self.respond_to? database_specific_method_name
      send database_specific_method_name, column.to_s, table.to_s
    else

      # try requiring 'activerecord-comments/[name-of-adapter]_adapter'
      begin

        # see if there right method exists after requiring
        require "activerecord-comments/#{ adapter }_adapter"
        if self.respond_to? database_specific_method_name
          send database_specific_method_name, column.to_s, table.to_s
        else
          raise ActiveRecord::Comments::UnsupportedDatabase.new("#{adapter} unsupported by ActiveRecord::Comments")
        end

      rescue LoadError
        raise ActiveRecord::Comments::UnsupportedDatabase.new("#{adapter} unsupported by ActiveRecord::Comments")
      end
    end
  end

  # Extends #columns, setting @parent as an instance variable 
  # on each of the column instances that are returned
  #
  # ==== Returns
  # Array[ActiveRecord::ConnectionAdapters::Column]::
  #   Returns an Array of column objects, each with @parent set
  #
  # :api: private
  def columns_with_parent *args
    columns = columns_without_parent *args
    parent = self
    columns.each do |column|
      column.instance_eval { @parent = parent }
    end
    columns
  end

end
