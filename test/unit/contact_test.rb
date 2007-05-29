require File.dirname(__FILE__) + '/../test_helper'

class ContactTest < Test::Unit::TestCase
  fixtures :contacts, :groups, :contacts_groups, :activities, :activities_contacts, :lead_sources
  
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
