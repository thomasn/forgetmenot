require File.dirname(__FILE__) + '/../test_helper'

class ContactTest < Test::Unit::TestCase
  fixtures :contacts, :groups, :contacts_groups
  
  def test_truth
    thomas = contacts(:thomas)
    assert_not_nil thomas
    assert_instance_of Contact, thomas
    assert_valid thomas
    assert thomas.errors.empty?
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

    renat = contacts(:renat)
    assert_not_nil renat.groups
    assert_equal 1, renat.groups.size
    renat.groups.each {|group|
      subtest_group group
    }
    assert renat.groups.include?(groups(:brainhouse))
    assert !renat.groups.include?(groups(:nexus10))

    yura = contacts(:yura)
    assert_not_nil yura.groups
    assert_equal 1, yura.groups.size
    yura.groups.each {|group|
      subtest_group group
    }
    assert yura.groups.include?(groups(:brainhouse))
    assert !yura.groups.include?(groups(:nexus10))
  end
  
  def subtest_group(group)
    assert_instance_of Group, group
    assert_valid group
    assert group.errors.empty?
  end
end
