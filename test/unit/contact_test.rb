# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

require File.dirname(__FILE__) + '/../test_helper'
require 'ferret'

class ContactTest < Test::Unit::TestCase
  ## CLEANUP - all fixtures preloaded ## fixtures :dynamic_attributes, :dynamic_attribute_values, :contacts, :groups, :contacts_groups, :activities, :activities_contacts, :lead_sources
    
  def setup
    # we have to do this because of unknown order of classes loading
    Contact.create_attributes
  end
  
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
    assert_equal 1, Contact.find_by_contents('Yury').total_hits

    # verify dynamic attribute value
    assert_equal 'yura__115', Contact.find_by_contents('Yury')[0].skype

    # find by dymanic attribute value
    assert_equal 1, Contact.find_by_contents('yura__115').total_hits

    # a bit advanced version of the find by dymanic attribute value
    assert_equal 1, Contact.find_by_contents('skype:yura__115').total_hits

    # let's create new attribute ...
    jid = DynamicAttribute.create :name => 'jabber', :type_name => 'string'

    # ... and check old index attributes still works fine
    assert_equal 1, Contact.find_by_contents('Yury').total_hits
    assert_equal 1, Contact.find_by_contents('skype:yura__115').total_hits

    # now assign some value to new attribute ...
    thomas = Contact.find contacts(:thomas).id
    thomas.jabber = 'ttttt'
    thomas.save!

    # ... and find by just created attribute
    assert_equal 1, Contact.find_by_contents('jabber:ttttt').total_hits
    assert_equal 1, Contact.find_by_contents('ttttt').total_hits

    # one more check of old attributes
    assert_equal 1, Contact.find_by_contents('Yury').total_hits
  end
  
   def test_dynamic_attributes_for_new_object
     values_count = DynamicAttributeValue.count
     
     # creating new contact
     yura = Contact.new :first_name => 'Yury', :last_name => 'Kazantsev', :skype => 'yukazan'
     assert_equal 'yukazan', yura.skype
     assert_equal values_count, DynamicAttributeValue.count
     
     # saving it
     assert_nothing_raised { yura.save! }
     assert_equal values_count + DynamicAttribute.count, DynamicAttributeValue.count
     
     # verifing dyn attr value
     yura = Contact.find_by_last_name('Kazantsev')
     assert_equal 'yukazan', yura.skype
     
     # searching by attr value
     assert_equal 1, Contact.find_by_contents('yukazan').total_hits
     
     # changing attribute value without saving...
     yura.skype = 'yurakazan'
     assert_equal 'yurakazan', yura.skype
     # ...should be no changes in the db ...
     assert_equal 'yukazan', Contact.find(yura.id).skype
     # ... as well as no changes in ferret index
     assert_equal 1, Contact.find_by_contents('yukazan').total_hits
     assert_equal 0, Contact.find_by_contents('yurakazan').total_hits
     
     yura.save!
     
     assert_equal 'yurakazan', Contact.find(yura.id).skype
     assert_equal 0, Contact.find_by_contents('yukazan').total_hits
     assert_equal 1, Contact.find_by_contents('yurakazan').total_hits
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
