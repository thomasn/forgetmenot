require File.dirname(__FILE__) + '/../test_helper'
require 'ferret'
require 'fileutils'
  
class ContactTest < Test::Unit::TestCase
  
  include Ferret
  INDEX_PATH = 'ferret-index'
  
  fixtures :dynamic_attributes, :dynamic_attribute_values, :contacts, :groups, :contacts_groups, :activities, :activities_contacts, :lead_sources

  def setup
    if File.exists?('index')
      FileUtils.rm_rf 'index'
      assert !File.exists?('index')
    end
  end

  def test_aaf
   Contact.acts_as_ferret :fields => [ :first_name ]
   assert Contact.find(:first).respond_to?(:first_name_to_ferret)

   assert_equal 1, Contact.find_by_contents('Y*').total_hits
   assert_equal 1, Contact.find_by_contents('first_name:Y*').total_hits
   
   assert File.exists?('index')
   Contact.aaf_index.ferret_index.close
   Contact.aaf_index.close
   FileUtils.rm_rf 'index'
   assert !File.exists?('index')

   Contact.acts_as_ferret :fields => [ :first_name, :last_name ]
   assert Contact.find(:first).respond_to?(:last_name_to_ferret)

   assert_equal 1, Contact.find_by_contents('Y*').total_hits
   assert_equal 1, Contact.find_by_contents('first_name:Y*').total_hits

   assert_equal 1, Contact.find_by_contents('last_name:K*').total_hits
   assert_equal 1, Contact.find_by_contents('first_name:Y* AND last_name:K*').total_hits
   assert_equal 1, Contact.find_by_contents('Kotlyarov').total_hits # assertion    
   assert_equal 1, Contact.find_by_contents('K*').total_hits # assertion    
  end
  
=begin
  def test_ferret
    if File.exists?(INDEX_PATH)
      FileUtils.rm_rf(INDEX_PATH)
      assert !File.exists?(INDEX_PATH)
    end
    index = Index::Index.new(:path => INDEX_PATH)  
    Contact.find(:all).each { |c| index << { :id => c.id, :first_name => c.first_name}; puts c.first_name }
    assert_equal 1, index.search('Y*').total_hits
    assert_equal 1, index.search('first_name:Y*').total_hits
    assert_equal 3, index.search('*a*').total_hits
    assert_equal 3, index.search('first_name:*a*').total_hits
    assert_equal 0, index.search('K*').total_hits
    assert_equal 0, index.search('last_name:K*').total_hits
    
    index.field_infos.add_field(:last_name)
    assert_equal 1, index.search('Y*').total_hits
    assert_equal 1, index.search('first_name:Y*').total_hits
    assert_equal 3, index.search('*a*').total_hits
    assert_equal 3, index.search('first_name:*a*').total_hits
    
    if File.exists?(INDEX_PATH)
      index.close
      FileUtils.rm_rf(INDEX_PATH)
      assert !File.exists?(INDEX_PATH)
    end
    index = Index::Index.new(:path => INDEX_PATH) 
    
    Contact.find(:all).each { |c| index << { :id => c.id, :first_name => c.first_name, :last_name => c.last_name }; puts c.first_name }

   
    (0..3).each { |i| index[i].load; puts "#{index[i][:id]}: #{index[i][:first_name]} #{index[i][:last_name]}" }
    
    
    assert_equal 1, index.search('last_name:K*').total_hits
    assert_equal 1, index.search('K*').total_hits

    assert_equal 1, index.search('first_name:Y* AND last_name:K*').total_hits
    assert_equal 1, index.search('first_name:R* AND last_name:A*').total_hits
    assert_equal 1, index.search('first_name:M* AND last_name:G*').total_hits
    
  end
=end

=begin
  def test_truth
    thomas = contacts(:thomas)
    assert_not_nil thomas
    assert_instance_of Contact, thomas
    assert_valid thomas
    assert thomas.errors.empty?
  end                          
  
  def test_display_name
    assert_equal contacts(:yura).first_name + ' ' + contacts(:yura).last_name, Contact.find(contacts(:yura).id).display_name
    c = Contact.create 
    assert_equal "contact ##{c.id}", c.display_name
    c = Contact.create :last_name => 'last_name'
    assert_equal 'last_name', c.display_name
    c = Contact.create :first_name => 'first_name'
    assert_equal 'first_name', c.display_name
  end

  def test_habtm_groups
    thomas = contacts(:thomas)
    assert_not_nil thomas.groups
    assert_equal 1, thomas.groups.size
    thomas.groups.each {|group|
      subtest_group group
    }
    assert !thomas.groups.include?(groups(:brainhouse))
    assert thomas.groups.include?(groups(:nexus10))
  end

  def test_habtm_activities
    thomas = Contact.find(contacts(:thomas).id)
    assert_not_nil thomas.activities
    assert_equal 1, thomas.activities.size
    thomas.activities.each {|a|
      subtest_activity a
    }
    assert !thomas.activities.include?(activities(:renat_and_yura_call_out))
    assert thomas.activities.include?(activities(:thomas_call_in))
  end
  
  def test_bt_addresses
    thomas = Contact.find(contacts(:thomas).id)
    assert_not_nil thomas.address
    assert_equal 1, thomas.address.id
    assert_not_nil thomas.address2
    assert_equal 2, thomas.address2.id
  end

  def test_bt_lead_source
    yura = Contact.find(contacts(:yura).id)
    assert_not_nil yura.lead_source
    assert_equal 2, yura.lead_source.id
  end
  
  def test_hierarchical
    assert !Contact.find(:first).hierarchical?
    assert !Contact.hierarchical?
  end

  def test_searchable
    assert Contact.find(:first).searchable?
    assert Contact.searchable?
  end

  def test_emailable
    assert Contact.find(:first).emailable?
    assert Contact.emailable?
  end

  def test_taggable
    assert Contact.find(:first).taggable?
    assert Contact.taggable?
  end

  def test_dynamic_attribute
    assert_not_nil DynamicAttribute.find_by_name('skype')
    assert Contact.find(:first).respond_to?(:first_name)
    assert !Contact.find(:first).respond_to?(:icq_number)
    assert Contact.find(:first).respond_to?(:skype)
    assert Contact.find(:first).respond_to?(:'skype=')
    assert !contacts(:yura).smokes
    
    martin = Contact.find(contacts(:martin).id)
    assert martin.smokes
    martin.smokes = false
    assert_nothing_raised { martin.save! }
    assert !Contact.find(martin.id).smokes
    
    thomas = contacts(:thomas)
    assert !thomas.smokes
    thomas.smokes = true
    assert_nothing_raised { thomas.save! }
    assert Contact.find(thomas.id).smokes
    
    jid = DynamicAttribute.create :name => 'jabber_id', :type_name => 'string'
    assert_nothing_raised { thomas.jabber_id }
    assert_nothing_raised { thomas.jabber_id = 'thomas@jabber.org' }
    assert_equal 'thomas@jabber.org', thomas.jabber_id
  end
  
  def test_search_by_dynamic_attributes
    result = Contact.find_by_contents('Yury')
    assert_not_nil result
    assert_equal 1, result.size 
    assert_equal contacts(:yura).id, result[0].id
    
    yura = contacts(:yura)
    assert_equal 'yura__115', yura.skype
    result = Contact.find_by_contents('yura__115')
    assert_not_nil result
    assert_equal 1, result.size 
    assert_equal contacts(:yura).id, result[0].id
    
    
    count = Contact.aaf_index.ferret_index.field_infos.size
    jid = DynamicAttribute.create :name => 'jabber_id', :type_name => 'string'
    assert_equal count+1, Contact.aaf_index.ferret_index.field_infos.size
    
    yura = contacts(:yura)
    assert_equal 'yura__115', yura.skype
    result = Contact.find_by_contents('yura__115')
    assert_not_nil result
    assert_equal 1, result.size 
    assert_equal contacts(:yura).id, result[0].id
    
    thomas = Contact.find(contacts(:thomas).id)
    thomas.jabber_id = 'thomas@jabber.org'
    result = Contact.find_by_contents('thomas@jabber.org')
    assert_not_nil result
    assert_equal 1, result.size 
    assert_equal contacts(:thomas).id, result[0].id

    result = Contact.find_by_contents('Yury')
    assert_not_nil result
    assert_equal 1, result.size 
    assert_equal contacts(:yura).id, result[0].id
  end

  def subtest_group(group)
    assert_instance_of Group, group
    assert_valid group
    assert group.errors.empty?
  end
  
  def subtest_activity(activity)
    assert_instance_of Activity, activity
    assert_valid activity
    assert activity.errors.empty?
  end
=end
  
end
