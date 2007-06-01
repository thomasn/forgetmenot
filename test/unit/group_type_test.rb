require File.dirname(__FILE__) + '/../test_helper'

class GroupTypeTest < Test::Unit::TestCase
  fixtures :dynamic_attributes, :dynamic_attribute_values, :group_types, :groups

  def test_truth
    t = GroupType.find(group_types(:prospect).id)
    assert_not_nil t
    assert_instance_of GroupType, t
    assert_valid t
    assert t.errors.empty?
    assert_equal group_types(:prospect), t
  end                          

  def test_display_name
    t = GroupType.find(group_types(:prospect).id)
    assert_equal t.name, t.display_name
    
    t = GroupType.create
    assert_equal "group type ##{t.id}", t.display_name
  end

  def test_habtm_groups
    t = GroupType.find(group_types(:prospect).id)
    assert_not_nil t.groups
    assert_equal 1, t.groups.size
    t.groups.each {|g|
      subtest_group g
    }
    assert !t.groups.include?(groups(:nexus10))
    assert t.groups.include?(groups(:brainhouse))
  end
  
  def subtest_group(group)
    assert_instance_of Group, group
    assert_valid group
    assert group.errors.empty?
  end
end
