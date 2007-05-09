require File.dirname(__FILE__) + '/../test_helper'
require 'activities_controller'

# Re-raise errors caught by the controller.
class ActivitiesController; def rescue_action(e) raise e end; end

class ActivitiesControllerTest < Test::Unit::TestCase
  fixtures :activities

  def setup
    @controller = ActivitiesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = activities(:renat_and_yura_call_out).id
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

    assert_not_nil assigns(:activities)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:activity)
    assert assigns(:activity).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:activity)
  end

  def test_create
    num_activities = Activity.count

    post :create, :activity => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_activities + 1, Activity.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:activity)
    assert assigns(:activity).valid?
  end

  def test_update
    post :update, :id => @first_id, :activity => { :description => 'hey' }
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Activity.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Activity.find(@first_id)
    }
  end
end
