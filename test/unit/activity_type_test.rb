require File.dirname(__FILE__) + '/../test_helper'

class ActivityTypeTest < Test::Unit::TestCase
  fixtures :dynamic_attributes, :dynamic_attribute_values, :activities, :activity_types
  
  def test_truth
    t = ActivityType.find(activity_types(:call_out).id)
    assert_not_nil t
    assert_instance_of ActivityType, t
    assert_valid t
    assert t.errors.empty?
    assert_equal activity_types(:call_out), t
  end                          

  def test_display_name
    t = ActivityType.find(activity_types(:call_out).id)
    assert_equal t.name, t.display_name
    
    t = ActivityType.create
    assert_equal "activity type ##{t.id}", t.display_name
  end

  def test_habtm_activities
    t = ActivityType.find(activity_types(:call_out).id)
    assert_not_nil t.activities
    assert_equal 2, t.activities.size
    t.activities.each {|a|
      subtest_activity a
    }
    assert !t.activities.include?(activities(:thomas_call_in))
    assert t.activities.include?(activities(:renat_and_yura_call_out))
    assert t.activities.include?(activities(:no_contacts_assigned_activity))
  end
  
  def subtest_activity(activity)
    assert_instance_of Activity, activity
    assert_valid activity
    assert activity.errors.empty?
  end
end
