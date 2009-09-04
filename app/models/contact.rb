# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)

require 'fileutils'

class Contact < ActiveRecord::Base
  has_and_belongs_to_many :activities
  has_and_belongs_to_many :groups
  belongs_to :address
  belongs_to :address2, :class_name => 'Address', :foreign_key => 'address2_id'
  belongs_to :lead_source

  ADDITIONAL_SEARCH_ATTRS = [ :contact_id, :zip, :postcode, :group, :parent_group ]
  
  private

  def dynamic_attribute_value(a)
    if self.id.nil?
      if new_dynamic_attribute_values.has_key?(a.name.to_sym) 
        value = new_dynamic_attribute_values[a.name.to_sym]
      else 
        value = DynamicAttributeValue.new :dynamic_attribute_id => a.id
        new_dynamic_attribute_values[a.name.to_sym] = value
      end
    else
      if new_dynamic_attribute_values.has_key?(a.name.to_sym) 
        value = new_dynamic_attribute_values[a.name.to_sym]
      else
        value = DynamicAttributeValue.find_by_dynamic_attribute_id_and_contact_id(a.id, self.id)
        value = DynamicAttributeValue.new :dynamic_attribute_id => a.id, :contact_id => self.id if value.nil?
        new_dynamic_attribute_values[a.name.to_sym] = value
      end
    end
    value
  end

  # Additional fields for search
  def contact_id
    self.id
  end

  def zip
    codes = []
    codes << self.address.zip if self.address
    codes << self.address2.zip if self.address2
    codes
  end

  alias :postcode :zip

  def group
    groups.collect(&:name)
  end

  def parent_group
    groups.collect { |g|
      Group.find(:all, :conditions => "root_id = #{g.root_id} AND (#{g.lft} BETWEEN lft AND rgt)", :order => 'lft' ) - [g] if !g.lft.nil? && !g.lft.zero?
    }.flatten.compact.uniq.collect(&:name)
  end

  def self.do_acts_as_ferret(attrs = DynamicAttribute.find(:all))
    additional_fields = attrs.collect { |a| a.name.to_sym } + ADDITIONAL_SEARCH_ATTRS

    acts_as_ferret :additional_fields => additional_fields
    # # FIXME: Bug in the acts_as_ferret. Workaround here - drop following line when bug will be fixed
    # ## FIXME - testing removal 2009-04-25 ## attrs.each { |a| aaf_index.ferret_index.options[:default_field] << a.name }
    drop_index_dir
  end

  def self.drop_index_dir # FIXME obsolete
    if File.exists?("#{RAILS_ROOT}/index")    # aaf_index.ferret_index.options[:path])
       begin
         aaf_index.close
       rescue
       end
                    FileUtils.rm_rf("#{RAILS_ROOT}/index")    # aaf_index.ferret_index.options[:path])
     end
  end
  

  public
  
  def self.searchable?
    true
  end

  def self.reindex(rails_env = nil)    # TODO implement without invoking rake
    rails_env ||= ENV["RAILS_ENV"]
    puts "rebuilding sphinx index for #{rails_env} environment"
    system "rake RAILS_ENV=#{rails_env} ts:rebuild > /tmp/rake-ts-rebuild.log"
  end
  
  
  def new_dynamic_attribute_values
    @new_dynamic_attribute_values ||= {}
  end

  # FIXME: make private
  # options: :force (boolean)
  def self.create_attributes(options = {})
    # If schema is just being created, this method is a no-op:
    return if not ActiveRecord::Base.connection.tables.include?("dynamic_attributes")
    if options[:force]
      DynamicAttribute.find(:all).each { |a| destroy_attribute(a) }
      @@attributes_created = nil
    end
    @@attributes_created ||= !!(DynamicAttribute.find(:all).each { |a| create_attribute(a, false) })
    # do_acts_as_ferret attrs
  end

  def self.create_attribute(a, recreate_index = false)
    # defining getter method
    define_method a.name do
      dynamic_attribute_value(a).send("#{a.type_name}_value")
    end

    # defining setter method
    define_method "#{a.name}=" do |new_value|
      dynamic_attribute_value(a).send("#{a.type_name}_value=", new_value)
    end

    # do_acts_as_ferret if recreate_index
  end
 
  def self.destroy_attribute(a)
    # undefine getter method
    undef_method a.name if method_defined? a.name
    # undefine setter method
    undef_method "#{a.name}=" if method_defined? "#{a.name}="
    # do_acts_as_ferret if recreate_index
  end
 

  # UltraSphinx indexing - FIXME clanup
  # is_indexed :fields => [ 'first_name', 'last_name', 'email', 'notes' ],
  #            :include => [ {:class_name => 'Address', :field => 'address1'} ]
  
  # ThinkingSphinx indexing
  ThinkingSphinx.deltas_enabled = true
  ThinkingSphinx.updates_enabled = true
  # ThinkingSphinx.suppress_delta_output = true # FIXME uncomment once tested in production
  define_index do
    indexes first_name, :sortable => true
    indexes last_name, :sortable => true
    indexes email, :sortable => true
    indexes notes

    # FIXME...
    # Add DynamicAttribute fields to index. Note that some Sphinx docs use the term "dynamic attributes" with a different meaning.
    Contact.create_attributes # FIXME obsolete?
    DynamicAttribute.find(:all).each do |da|
      cmd = "(SELECT string_value FROM dynamic_attribute_values WHERE (dynamic_attribute_values.contact_id = " +
      "contacts.id" +
      " AND dynamic_attribute_values.dynamic_attribute_id = " +
        "#{da.id}" +
      ") LIMIT 1)"
      indexes "#{cmd}", :as => "#{da.name}".to_sym
      
    end
###    indexes "(SELECT string_value FROM dynamic_attribute_values WHERE (dynamic_attribute_values.contact_id = 2032 AND
### dynamic_attribute_values.dynamic_attribute_id = 16) LIMIT 1)", :as => :enquiry_codes
    
    set_property :enable_star => 1
    set_property :min_infix_len => 3
    set_property :delta => true
    
    # attributes - used for sorting results etc:
    # has created_at, updated_at # FIXME add timestamp migration
  end
  
  
  acts_as_taggable
  after_create { |c| c.new_dynamic_attribute_values.values.each { |v| v.contact_id = c.id; v.save }  }
  after_update { |c| c.new_dynamic_attribute_values.values.each { |v| v.save }  }

  def display_name
    fname = self.first_name.blank?  ? "--" : self.first_name.strip
    lname = self.last_name.blank?  ? "--" : self.last_name.strip

    self.first_name.nil? && self.last_name.nil? ? "contact ##{self.id}" : "#{lname}, #{fname}"
  end

  alias_method :old_column_for_attribute, :column_for_attribute
  def column_for_attribute(method_name)
    obj = old_column_for_attribute(method_name)
    obj.nil? ? DynamicAttribute.find_by_name(method_name).column : obj
  end

end

Contact::create_attributes
