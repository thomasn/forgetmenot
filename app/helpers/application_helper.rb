require 'rubygems'
require 'maruku'

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  SKIP_COLUMN_LIST = [ 'lft', 'rgt', 'parent_id', 'root_id', 'depth' ]
  
  def get_multiple_associations(class_name, show_when_associated_table_is_empty = false)
    ( eval(class_name).reflect_on_all_associations(:has_and_belongs_to_many) + 
      eval(class_name).reflect_on_all_associations(:has_many)).collect {|a| 
        a if show_when_associated_table_is_empty || a.class_name.constantize.count > 0 }.compact
  end
  
  def get_single_associations(class_name, show_when_associated_table_is_empty = false)
    eval(class_name).reflect_on_all_associations(:belongs_to).collect {|a| 
      a if show_when_associated_table_is_empty || a.class_name.constantize.count > 0}.compact
  end
  
  def get_entity_columns(entity_class)
    entity_class.content_columns.collect {|c| c unless SKIP_COLUMN_LIST.include?(c.name)}.compact 
  end
  
  def get_table_names
    ActiveRecord::Base.establish_connection
    (ActiveRecord::Base.connection.tables - ['schema_info']).collect {|table|
      table unless ActiveRecord::Base.connection.columns(table).collect { |column|
        column if column.name == 'id'
      }.compact.empty?
    }.compact
  end
  
  def referer
    if request.env['HTTP_REFERER'] =~ /\/(\w+)\/show\/(\d+)$/
      $1.classify.constantize.find($2)
    end 
  end
  
  def markdown(string)
    Maruku.new(string).to_html
  end

  # methods for hierarchical entities support
 
  def is_entity_hierarchical(entity_class)
    entity_class.columns.collect{ |c| c.name }.include?('parent_id')
  end
  
  def get_hierarchy(entity_class)
    "<ul>" + entity_class.find(:all, :conditions => 'parent_id IS NULL or parent_id = 0', :order => 'root_id, lft').collect {|root|
      get_subtree(root) }.join + "</ul>"
  end
  
  def get_subtree(node)
    %Q{<li>#{link_to node.display_name, :action => 'list', :parent_id => node.id}
      #{node.direct_children.collect {|child| "<ul>#{get_subtree(child)}</ul>"}.join unless node.lft.nil?}</li>}
  end
  
  def breadcrumbs(object)
    return "" unless is_entity_hierarchical(object.class) && !object.lft.nil?
    (entity_class.find(:all, { :conditions => "root_id = #{object.root_id} AND (#{object.lft} BETWEEN lft AND rgt)", :order => "lft" }) - [object]).collect { |e|
      link_to e.display_name, :id => e.id
    }.push(object.display_name).join(" > ")
  end
end
