# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

module CommonHelper

  def div_parity(num)
    a = num/2
    a = a*2
    if a == num
      "right"
    else
      "left"
    end
  end
  
  def number_of_columns
    i = 0
    @object.get_entity_columns.collect { |column|
      i += 1
    }
    i
  end
  
  def div_columns(i)
    columns = number_of_columns
    columns = columns/2
    if i <= columns
      "left"
    else
      "right"
    end
  end
  
  # Orders by the correct field in the database
  def order_by(class_name)
    if class_name == 'Group'
      'name'
    elsif class_name == 'EmailMessage'
      'subject'    # TODO or add created_at to model and use as sort field
    else 
      'id'
    end
  end

  def build_form
    i = 0
    @object.get_entity_columns.collect { |column|
      i += 1
      if column.name != 'notes'
      	if i == 1 && ( params[:table_name] == 'contacts' || params[:table_name] == 'addresses' || params[:table_name] == 'groups' || params[:table_name] == 'dynamic_attributes' || params[:table_name] == 'users' || params[:table_name] == 'activities' )
          result = "<div id=\"col\"><p><label for=\"object_#{column.name}\">#{column.name.humanize}</label>"
      	else
          result = "<p><label for=\"object_#{column.name}\">#{column.name.humanize}</label>"
      	end
      else
      	result = "<br /></fieldset>\n<fieldset><legend>Step 2</legend>\n<p><label for=\"object_#{column.name}\">#{column.name.humanize}</label>"
      	result += "<br /><i>Markdown available (<a href=\"http://maruku.rubyforge.org/#features\">see syntax details</a>)</i>"
      end 
      
      if params[:table_name] == 'dynamic_attributes' && column.name == 'type_name'
        result += "<br/>\n#{select('object', column.name, get_dynamic_attribute_type_names)}"
      else
        result += "<br/>\n#{input('object', column.name)}"       
      end
      result +="</p>\n"
      result += "\n</div>\n<div id=\"col\">\n" if i == number_of_columns/2
      result += "</fieldset>" if column.name == 'notes'
      result  
    }.join("\n")
  end

end
