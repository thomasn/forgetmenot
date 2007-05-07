require File.dirname(__FILE__) + '/../test_helper'
require 'groups_controller'

# Re-raise errors caught by the controller.
class GroupsController; def rescue_action(e) raise e end; end

class GroupsControllerTest < Test::Unit::TestCase
  fixtures :groups, :contacts, :contacts_groups

  def setup
    @controller = GroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = groups(:brainhouse).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:groups)
    
    assert_select 'th', 'Contacts'

    assert_select "div[style='display: none']" do
      assert_select 'a[href="/contacts/show/3"]', 'Yury Kotlyarov'
      assert_select 'a[href="/contacts/show/2"]', 'Renat Akhmerov'
    end
  end
  
  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:group)
    assert assigns(:group).valid?
    
    assert_select 'h2'
    assert_select 'h2', 'Contacts'
    assert_select 'a[href^="/contacts/show/"]', 2
    assert_select 'a[href="/contacts/show/3"]', 'Yury Kotlyarov'
    assert_select 'a[href="/contacts/show/2"]', 'Renat Akhmerov'
    
    get :show, :id => groups(:empty_group).id
    assert_select 'h2', { :text => 'Contacts', :count => 0 }, 'There is no contacts for empty group'
    assert_select 'a[href^="/contacts/show/"]', false
    
    get :show, :id => groups(:nexus10).id
    assert_select 'h2', 'Contacts'
    assert_select 'a[href^="/contacts/show/"]', 1

  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:group)
  end

  def test_create
    num_groups = Group.count

    post :create, :group => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_groups + 1, Group.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:group)
    assert assigns(:group).valid?
    
    assert_select 'h2', 'Manage contacts'
    assert_select 'div#group_contacts' do
      assert_select 'h3', 'Group contacts'
      assert_select 'select' do
        assert_select 'option', Group.find(@first_id).contacts.size
      end
    end

    assert_select 'div#other_contacts' do
      assert_select 'h3', 'Other contacts'
      assert_select 'select' do
        assert_select 'option', Contact.count - Group.find(@first_id).contacts.size
      end
    end
    
    assert_select 'input[type=button][value="&lt; Add selected"]'
    assert_select 'input[type=button][value="&lt;&lt; Add all"]'
    assert_select 'input[type=button][value="Remove selected &gt;"]'
    assert_select 'input[type=button][value="Remove all &gt;&gt;"]'
    
  end

  def test_update_with_empty_contact_ids
    assert_equal 2, Group.find(@first_id).contacts.size
    
    post :update, :id => @first_id, :group => { :name => 'BrainHouse LLC.'}
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
    
    assert_equal 0, Group.find(@first_id).contacts.size
  end

  def test_update_with_different_contact_id
    assert_equal 1, groups(:nexus10).contacts.size
    assert_equal contacts(:thomas), groups(:nexus10).contacts[0]
    
    post :update, :id => groups(:nexus10).id, :group => { :name => 'Nexus 11', :contact_ids => ["4"] }
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => groups(:nexus10).id
    
    assert_equal 1, Group.find(groups(:nexus10).id).contacts.size
    assert_equal contacts(:martin), Group.find(groups(:nexus10).id).contacts[0]
  end

  def test_update_with_several_contact_ids
    assert_equal 1, groups(:nexus10).contacts.size
    assert_equal contacts(:thomas), groups(:nexus10).contacts[0]
    
    post :update, :id => groups(:nexus10).id, :group => { :name => 'Nexus 11', :contact_ids => ["1", "4"] }, :commit => "Edit"
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => groups(:nexus10).id
    
    assert_equal 2, Group.find(groups(:nexus10).id).contacts.size
    assert Group.find(groups(:nexus10).id).contacts.include?(contacts(:thomas))
    assert Group.find(groups(:nexus10).id).contacts.include?(contacts(:martin))
  end
  
  def test_destroy
    assert_nothing_raised {
      Group.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Group.find(@first_id)
    }
  end
end
