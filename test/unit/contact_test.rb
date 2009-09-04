# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

require File.dirname(__FILE__) + '/../test_helper'
require 'ferret'

class ContactTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false
  fixtures :dynamic_attributes, :dynamic_attribute_values, :contacts, :groups, :contacts_groups, :activities, :activities_contacts, :lead_sources
    
  def setup
    # we have to do this because of unknown order of classes loading
    Contact.create_attributes(:force => true)
  end
  
  def test_truth
    thomas = contacts(:thomas)
    assert_not_nil thomas
    assert_instance_of Contact, thomas
    assert_valid thomas
    assert thomas.errors.empty?
  end

  def test_display_name
    assert_equal contacts(:yura).last_name + ', ' + contacts(:yura).first_name, Contact.find(contacts(:yura).id).display_name
    c = Contact.create 
    assert_equal "contact ##{c.id}", c.display_name
    c = Contact.create :last_name => 'last_name'
    assert_equal 'last_name, --', c.display_name
    c = Contact.create :first_name => 'first_name'
    assert_equal '--, first_name', c.display_name
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
    # check whether fixtures loaded ok
    assert_not_nil DynamicAttribute.find_by_name('skype')

    # check regular AR attribute
    assert Contact.find(:first).respond_to?(:first_name)

    # there is no 'icq_number' attribute here
    assert !Contact.find(:first).respond_to?(:icq_number)

    # but we have dynamic 'skype' attribute getter ...
    assert Contact.find(:first).respond_to?(:skype)

    # ... and setter
    assert Contact.find(:first).respond_to?(:'skype=')

    # the same checks for completely new attribute
    DynamicAttribute.create :name => 'jabber_id', :type_name => 'string'
    assert Contact.find(:first).respond_to?(:jabber_id)
    assert Contact.find(:first).respond_to?(:'jabber_id=')
  end

  def test_dynamic_attribute_values
    # Yury doesn't smoke
    assert !contacts(:yura).smokes

    # Martin does
    martin = Contact.find(contacts(:martin).id)
    assert martin.smokes

    # but not anymore
    martin.smokes = false
    assert_nothing_raised { martin.save! }
    assert !Contact.find(martin.id).smokes

    # Thomas doesn't smoke
    thomas = contacts(:thomas)
    assert !thomas.smokes

    # but sometimes ...
    thomas.smokes = true
    assert_nothing_raised { thomas.save! }
    assert Contact.find(thomas.id).smokes

    # the same checks for completely new attribute
    jid = DynamicAttribute.create :name => 'jabber_id', :type_name => 'string'
    assert_nil thomas.jabber_id
    assert_nothing_raised { thomas.jabber_id = 'thomas@jabber.org' }
    assert_nothing_raised { thomas.save! }
    assert_equal 'thomas@jabber.org', Contact.find(thomas.id).jabber_id
  end

  def test_search_by_dynamic_attributes
    # find by a regular AR attribute value
    # delta index may return spurious nil values so need to compact
    assert_equal 1, Contact.search('Yury').compact.size

    # verify dynamic attribute value
    assert_equal 'yura__115', Contact.search('Yury')[0].skype

    # find by dymanic attribute value
    assert_equal 1, Contact.search('yura__115').compact.size

    # a more advanced version of searching by dynamic attribute value, using a named field
    assert_equal 1, Contact.search('@skype yura__115', :match_mode => :extended).compact.size

    # let's create new attribute ...
    jid = DynamicAttribute.create :name => 'jabber', :type_name => 'string'

    # ... and check old index attributes still works fine
    assert_equal 1, Contact.search('Yury').compact.size
    assert_equal 1, Contact.search('yura__115').compact.size
    assert_equal 1, Contact.search('@skype yura__115', :match_mode => :extended).compact.size

    # now assign some value to new attribute ...
    thomas = Contact.find contacts(:thomas).id
    thomas.jabber = 'ttttt'
    thomas.save!

    # ... and find by just created attribute
    # Rebuild index because there is a new dynamic attribute
    Contact.create_attributes(:force => true)
    Contact.reindex
    assert_equal 1, Contact.search('@jabber ttttt', :match_mode => :extended).compact.size
    assert_equal 1, Contact.search('ttttt').compact.size

    # one more check of old attributes
    assert_equal 1, Contact.search('Yury').compact.size
  end
  
   def test_dynamic_attributes_for_new_object
     values_count = DynamicAttributeValue.count
     
     # creating new contact
     yura = Contact.new :first_name => 'Yury', :last_name => 'Kazantsev', :skype => 'yukazan'
     assert_equal 'yukazan', yura.skype
     assert_equal values_count, DynamicAttributeValue.count
     
     # saving it
     assert_nothing_raised { yura.save! }
     assert_equal 2, values_count
     assert_equal "age:amount:bio:birthdate:skype:smokes", DynamicAttribute.find(:all).map{ |a| a.name}.sort.join(':').to_s
     assert_equal 6, DynamicAttribute.count
     assert_equal 3, DynamicAttributeValue.count
     
     # verifing dyn attr value
     yura = Contact.find_by_last_name('Kazantsev')
     assert_equal 'Yury', yura.first_name
     assert_equal 'yukazan', yura.skype
     
     # searching by attr value
     ## puts "### FIXME transactional_fixtures == #{self.use_transactional_fixtures}"
     ## puts "### FIXME instantiated_fixtures == #{self.use_instantiated_fixtures}"
     ## puts "### FIXME 001: deltas_enabled == #{ ThinkingSphinx.deltas_enabled? } -- hit <Enter>"
     ## gets ### FIXME
     assert_equal 1, Contact.search('Kazantsev').compact.size
     ## puts "### FIXME 002:  -- hit <Enter>"
     ## gets ### FIXME
     # searching by dynattr value
     assert_equal 1, Contact.search('yukazan').compact.size
     
     # changing attribute value without saving...
     yura.skype = 'yurakazan'
     assert_equal 'yurakazan', yura.skype
     # ...should be no changes in the db ...
     assert_equal 'yukazan', Contact.find(yura.id).skype
     # ... as well as no changes in sphinx index
     assert_equal 1, Contact.search('yukazan').compact.size
     assert_equal 0, Contact.search('yurakazan').compact.size
     
     yura.save!
     
     assert_equal 'yurakazan', Contact.find(yura.id).skype
     assert_equal 0, Contact.search('yukazan').compact.size
     assert_equal 1, Contact.search('yurakazan').compact.size
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

end
