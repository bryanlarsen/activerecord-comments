module ActiveRecord::Comments::ColumnExt
  attr_reader :parent

  def comment
    raise "parent not set for column #{ self.inspect }" if parent.nil?
    parent.send(:column_comment, name, parent.table_name)
  end
end
