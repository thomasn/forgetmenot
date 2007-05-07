require File.dirname(__FILE__) + '/../test_helper'
require 'contacts_controller'

# Re-raise errors caught by the controller.
class ContactsController; def rescue_action(e) raise e end; end

class ContactsControllerTest < Test::Unit::TestCase
  fixtures :contacts

  def setup
    @controller = ContactsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = contacts(:thomas).id
  end

  def test_index
    get :index
    assert_response :success

    assert_not_nil assigns(:contacts)
    assert_equal 4, assigns(:contacts).size
    assert_not_nil assigns(:contact_pages)
    
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    
    assert_not_nil assigns(:contacts)
    assert_equal 4, assigns(:contacts).size
    assert_not_nil assigns(:contact_pages)

    assert_template 'list'
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:contact)
    assert assigns(:contact).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:contact)
  end

  def test_create
    num_contacts = Contact.count

    post :create, :contact => {:first_name => 'Martin', :last_name => 'Griffins'}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_contacts + 1, Contact.count
    assert_not_nil Contact.find_by_first_name_and_last_name('Martin', 'Griffins')
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:contact)
    assert assigns(:contact).valid?
  end

  def test_update
    post :update, :id => @first_id, :contact => { :first_name => 'Tom' }
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
    assert_not_nil Contact.find_by_first_name_and_last_name('Tom', 'Nichols')
    assert_nil Contact.find_by_first_name_and_last_name('Thomas', 'Nichols')
  end

  def test_destroy
    assert_nothing_raised {
      Contact.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Contact.find(@first_id)
    }
  end
end

=begin
require File.dirname(__FILE__) + '/../test_helper'
require 'alert_controller'

# Re-raise errors caught by the controller.
class AlertController; def rescue_action(e) raise e end; end

class AlertControllerTest < Test::Unit::TestCase

  fixtures :tblsubscriptions, :tblregusers, :tblfeedtypes, :tblfeeds, :tblfeedtypessubscriptions

  def setup
    @controller = AlertController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @radha = User.find_by_Name('Radha Stirling')
  end

  def test_index
    get :index
    assert_redirected_to :controller => "login", :action => "login"
  end

  def test_index
# FIXME: login controller looks inconsistent
#    get :index
#    assert_redirected_to :controller => "login", :action => "login"
  end

  def test_index_with_user
    get :index, {}, { :user => @radha  }
    assert_response :success
    assert_template "index"
  end

  def test_feed_types
    get :index, {}, { :user => @radha }
    assert_response :success
    assert_template "index"

    1.upto(9) {|i|
      if i == 7
        assert_select "input[type=radio][name='feed_types_subscriptions[#{i}]'][value=true][checked]", 1
        assert_select "input[type=radio][name='feed_types_subscriptions[#{i}]'][value=false][checked]", false
      else
        assert_select "input[type=radio][name='feed_types_subscriptions[#{i}]'][value=true][checked]", false
        assert_select "input[type=radio][name='feed_types_subscriptions[#{i}]'][value=false][checked]", 1
      end
    }

    assert_select "input[type=radio][name='subscription[frequency]'][value=weekly][checked]", 1
    assert_select "input[type=radio][name='subscription[frequency]'][value=daily]", 1
    assert_select "input[type=radio][name='subscription[frequency]'][value=immediately]", 1
    assert_select "input[type=radio][name='subscription[frequency]'][value=daily][checked]", false
    assert_select "input[type=radio][name='subscription[frequency]'][value=immediately][checked]", false

    post :index,
      {"commit"=>"Update my alerts", "feed_types_subscriptions"=>{"6"=>"true", "7"=>"true", "8"=>"true", "9"=>"true", "1"=>"true", "2"=>"true", "3"=>"true", "4"=>"true", "5"=>"true"}, "action"=>"index", "id"=>"5", "controller"=>"alert", "subscription"=>{"frequency"=>"daily"}},
      { :user => @radha }

    1.upto(9) {|i|
      assert_select "input[type=radio][name='feed_types_subscriptions[#{i}]'][value=true][checked]", 1
      assert_select "input[type=radio][name='feed_types_subscriptions[#{i}]'][value=false][checked]", false
    }

    assert_select "input[type=radio][name='subscription[frequency]'][value=daily][checked]", 1
    assert_select "input[type=radio][name='subscription[frequency]'][value=weekly]", 1
    assert_select "input[type=radio][name='subscription[frequency]'][value=immediately]", 1
    assert_select "input[type=radio][name='subscription[frequency]'][value=weekly][checked]", false
    assert_select "input[type=radio][name='subscription[frequency]'][value=immediately][checked]", false

    post :index,
      {"commit"=>"Update my alerts", "feed_types_subscriptions"=>{"6"=>"false", "7"=>"false", "8"=>"false", "9"=>"false", "1"=>"false", "2"=>"false", "3"=>"false", "4"=>"false", "5"=>"false"}, "action"=>"index", "id"=>"5", "controller"=>"alert", "subscription"=>{"frequency"=>"immediately"}},
      { :user => @radha }

    1.upto(9) {|i|
      assert_select "input[type=radio][name='feed_types_subscriptions[#{i}]'][value=true][checked]", false
      assert_select "input[type=radio][name='feed_types_subscriptions[#{i}]'][value=false][checked]", 1
    }

    assert_select "input[type=radio][name='subscription[frequency]'][value=immediately][checked]", 1
    assert_select "input[type=radio][name='subscription[frequency]'][value=weekly]", 1
    assert_select "input[type=radio][name='subscription[frequency]'][value=daily]", 1
    assert_select "input[type=radio][name='subscription[frequency]'][value=weekly][checked]", false
    assert_select "input[type=radio][name='subscription[frequency]'][value=daily][checked]", false
  end
end
=end
