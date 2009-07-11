# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

# Using ActionView::TestCase as per http://technicalpickles.com/posts/helper-testing-using-actionview-testcase

require File.dirname(__FILE__) + '/../../test_helper'
require 'action_view/test_case'
class ApplicationHelperTest < ActionView::TestCase
  ### tests ApplicationHelper
  ### include ApplicationHelper

   fixtures :dynamic_attributes, :dynamic_attribute_values, :contacts, :groups

  def setup
    super
  end

  def test_get_subtree
    # test for leaf
    group = Group.find(groups(:brainhouse_crm_division).id)
    subtree = get_subtree(group)
    assert_not_nil subtree
    assert_instance_of String, subtree
    assert_equal %Q{<li><a href="/groups/list?parent_id=#{group.id}">#{group.display_name}</a></li>}, subtree
    
    group = Group.find(groups(:empty_group).id)
    subtree = get_subtree(group)
    assert_not_nil subtree
    assert_instance_of String, subtree
    assert_equal %Q{<li><a href="/groups/list?parent_id=#{group.id}">#{group.display_name}</a></li>}, subtree
    
    #test for tree
    group = Group.find(groups(:brainhouse_cms_division).id)
    child = Group.find(groups(:brainhouse_railfrog_cms_team).id)
    subtree = get_subtree(group)
    assert_not_nil subtree
    assert_instance_of String, subtree
    assert_equal %Q{<li><a href="/groups/list?parent_id=#{group.id}">#{group.display_name}</a><ul><li><a href="/groups/list?parent_id=#{child.id}">#{child.display_name}</a></li></ul></li>}, subtree
  end
  
  def test_get_hierarchy
    hierarchy = get_hierarchy Group
    assert_not_nil hierarchy
    assert_instance_of String, hierarchy
    assert !hierarchy.strip.empty?
    
    html = HTML::Document.new(hierarchy).root

    selector = HTML::Selector.new "ul:root"
    assert_equal 1, selector.select(html).size
    
    selector = HTML::Selector.new "ul:root>li"
    assert_equal 3, selector.select(html).size

    selector = HTML::Selector.new "ul:root>li:first-child>a"
    group = Group.find(groups(:brainhouse).id)
    assert_equal %Q{<a href="/groups/list?parent_id=#{group.id}">#{group.display_name}</a>}, selector.select(html).to_s
    
    selector = HTML::Selector.new "ul:root>li>ul"
    assert_equal 3, selector.select(html).size

    selector = HTML::Selector.new "ul:root>li>ul>li"
    assert_equal 3, selector.select(html).size

    selector = HTML::Selector.new "ul:root>li>ul>li>ul"
    assert_equal 1, selector.select(html).size
    
    selector = HTML::Selector.new "ul:root>li>ul>li>ul>li"
    assert_equal 1, selector.select(html).size

    group = Group.find(groups(:brainhouse_railfrog_cms_team).id)
    assert_equal %Q{<li><a href="/groups/list?parent_id=#{group.id}">#{group.display_name}</a></li>}, selector.select(html).to_s
  end
  
  def test_breadcrumbs
    
  end

  
end
