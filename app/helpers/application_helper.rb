# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def get_associations(class_name)
    eval(class_name).reflect_on_all_associations(:has_and_belongs_to_many).collect {|a| a if eval(a.name.to_s.camelize.singularize).count > 0 }.compact
  end
end
