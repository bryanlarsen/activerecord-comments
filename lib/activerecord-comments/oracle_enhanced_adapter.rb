module ActiveRecord::Comments::OracleEnhancedAdapter

  def self.included base
    base.extend ClassMethods
  end

  module ClassMethods

    # Oracle Enhanced implementation of ActiveRecord::Comments::BaseExt#comment
    def oracle_enhanced_comment table
      connection.table_comment table
    end

    # Oracle Enhanced implementation of ActiveRecord::Comments::BaseExt#column_comment
    def oracle_enhanced_column_comment column, table
      connection.column_comment table, column
    end

  end

end

ActiveRecord::Base.send :include, ActiveRecord::Comments::OracleEnhancedAdapter

################ WE SHOULD DO EVERYTHING ON THE CONNECTION (ADAPTER) INSTEAD!!!!!!

module ActiveRecord::Comments::OracleEnhancedAdapterAdapter

  # Oracle Enhanced implementation of ActiveRecord::Comments::BaseExt#comment
  def oracle_enhanced_comment table
    table_comment table
  end

  # Oracle Enhanced implementation of ActiveRecord::Comments::BaseExt#column_comment
  def oracle_enhanced_column_comment column, table
    column_comment table, column
  end

end

ActiveRecord::ConnectionAdapters::AbstractAdapter.send :include, ActiveRecord::Comments::OracleEnhancedAdapterAdapter
