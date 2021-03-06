module ActiveRecord::Comments::BaseExt

  def self.included base
    base.extend ClassMethods

    base.instance_eval {
      class << self
        alias_method_chain :columns, :parent # this is evil!!!  how to fix?  column needs to know its table  :(
      end
    }
  end

  module ClassMethods

    # Get the database comment (if any) defined for a table
    #
    # ==== Parameters
    # table<~to_s>::
    #   The name of the table to get the comment for, default is 
    #   the #table_name of the ActiveRecord::Base class this is 
    #   being called on, eg. +User.comment+
    #
    # ==== Returns
    # String:: The comment for the given table (or nil if no comment)
    #
    # :api: public
    def comment table = self.table_name
      connection.comment table
    end

    # Get the database comment (if any) defined for a column
    #
    # TODO move into adapter!
    #
    # ==== Parameters
    # column<~to_s>::
    #   The name of the column to get the comment for
    #
    # table<~to_s>::
    #   The name of the table to get the column comment for, default is 
    #   the #table_name of the ActiveRecord::Base class this is 
    #   being called on, eg. +User.column_comment 'username'+
    #
    # ==== Returns
    # String:: The comment for the given column (or nil if no comment)
    #
    # :api: public
    def column_comment column, table = self.table_name
      connection.column_comment column, table
    end

    # Extends ActiveRecord::Base#columns, setting @table_name as an instance variable 
    # on each of the column instances that are returned
    #
    # ==== Returns
    # Array[ActiveRecord::ConnectionAdapters::Column]::
    #   Returns an Array of column objects, each with @table_name set
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

end
