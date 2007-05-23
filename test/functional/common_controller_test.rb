require File.dirname(__FILE__) + '/../test_helper'
require 'common_controller'

# Re-raise errors caught by the controller.
class CommonController; def rescue_action(e) raise e end; end

class CommonControllerTest < Test::Unit::TestCase
  fixtures :groups, :contacts, :contacts_groups, :activities, :activity_types, :activities_contacts
 
  def setup
    @controller = CommonController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index, { :table_name => 'activities' }, { :user => 1 }
    assert_response :success
    assert_template 'list'
  end
  
  def test_main_menu
    get :index, { :table_name => 'contacts' }, { :user => 1 }
    subtest_main_menu 'contacts'

    get :index, { :table_name => 'groups' }, { :user => 1 }
    subtest_main_menu 'groups'
    
    get :index, { :table_name => 'activities' }, { :user => 1 }
    subtest_main_menu 'activities'
    
    get :index, { :table_name => 'activity_types' }, { :user => 1 }
    subtest_main_menu 'activity_types'
  end
  
  def subtest_main_menu(element)
    assert_select 'div#main_menu ul li.active', 1
    assert_select 'div#main_menu ul li.active a', element.humanize
    assert_select "div#main_menu ul li.active a[href=/#{element}]", element.humanize
  end
  
  def test_list__activities
    get :list, { :table_name => 'activities' }, { :user => 1 }

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:objects)
    
    assert_select 'h1', 'Listing activities'
    
    assert_select 'th', 5
    assert_select 'th', 'Notes'
    assert_select 'th', 'Activity type'
    assert_select 'th', 'Contacts'
    
    assert_select 'td', activity_types(:email_in).name
    assert_select 'td', activity_types(:call_in).name
    assert_select 'td', activity_types(:call_out).name

    assert_select "div[style='display: none']" do
      assert_select 'a[href="/contacts/show/3"]', contacts(:yura).display_name
      assert_select 'a[href="/contacts/show/2"]', contacts(:renat).display_name
    end

    Activity.find(:all).each { |a|
      assert_select "td a[href=/activities/show/#{a.id}]", { :text => 'Show', :count => 1 }
      assert_select "td a[href=/activities/edit/#{a.id}]", { :text => 'Edit', :count => 1 }
      assert_select "td a[href=/activities/destroy/#{a.id}]", { :text => 'Delete', :count => 1 } 
    }
    
    assert_select 'tr', Activity.count + 1
    
    assert_select 'input#query', false
    assert_select 'input[value=Search]', false
  end

  def test_list__activity_types
    get :list, { :table_name => 'activity_types' }, { :user => 1 }

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:objects)
    
    assert_select 'h1', 'Listing activity types'
    
    assert_select 'th', 2
    assert_select 'th', 'Name'
    assert_select 'th', 'Activities'
    
    assert_select 'td', activity_types(:email_in).name
    assert_select 'td', activity_types(:call_in).name
    assert_select 'td', activity_types(:call_out).name

    assert_select "div[style='display: none']" do
      assert_select 'a[href="/activities/show/1"]', activities(:renat_and_yura_call_out).display_name
    end

    ActivityType.find(:all).each { |t|
      assert_select "td a[href=/activity_types/show/#{t.id}]", { :text => 'Show', :count => 1 }
      assert_select "td a[href=/activity_types/edit/#{t.id}]", { :text => 'Edit', :count => 1 }
      assert_select "td a[href=/activity_types/destroy/#{t.id}]", { :text => 'Delete', :count => 1 } 
    }
    
    assert_select 'tr', ActivityType.count + 1
  end
  
  def test_show__activity
    get :show, { :table_name => 'activities', :id =>  activities(:renat_and_yura_call_out).id }, { :user => 1 }

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:object)
    assert assigns(:object).valid?

    assert_select 'b', 'Time:'
    assert_select 'b', 'Activity type:'
    
    assert_select 'p', /Mon Jan 01 14:00:00 \S+ 2007/
    assert_select 'p', /#{activities(:renat_and_yura_call_out).activity_type.display_name}/
    
    assert_select 'h2', 'Contacts'
    
    assert_select 'a[href^="/contacts/show/"]', 2
    assert_select 'a[href="/contacts/show/3"]', 'Yury Kotlyarov'
    assert_select 'a[href="/contacts/show/2"]', 'Renat Akhmerov'

    get :show, { :table_name => 'activities', :id => activities(:no_contacts_assigned_activity).id }, { :user => 1 }
    assert_response :success
    assert_template 'show'
    assert_select 'h2', 'Contacts'
    assert_select 'a[href^="/contacts/show/"]', false
    
    get :show, { :table_name => 'activities', :id => activities(:no_activity_type_assigned).id }, { :user => 1 }
    assert_response :success
    assert_template 'show'
    assert_select 'p b', 'Activity type:'
  end

  def test_show__activity_type
    get :show, { :table_name => 'activity_types', :id =>  activity_types(:call_out).id }, { :user => 1 }
    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:object)
    assert assigns(:object).valid?

    assert_select 'b', 'Name:'
    assert_select 'p', /#{activity_types(:call_out).name}/
    assert_select 'h2', 'Activities'
    
    assert_select 'a[href^="/activities/show/"]', 2
    assert_select 'a[href="/activities/show/1"]', activities(:renat_and_yura_call_out).display_name
    assert_select 'a[href="/activities/show/4"]', activities(:no_contacts_assigned_activity).display_name

    get :show, { :table_name => 'activity_types', :id => activity_types(:no_assigned_activities).id }, { :user => 1 }
    assert_response :success
    assert_template 'show'
    assert_select 'h2', 'Activities'
    assert_select 'a[href^="/activities/show/"]', false
  end


  def test_new__activity
    get :new, { :table_name => 'activities' }, { :user => 1 }
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:object)
    
    assert_select 'h1', 'New activity'
    assert_select 'textarea#object_notes', 1
    assert_select 'select#object_activity_type_id', 1
    assert_select 'select#object_activity_type_id option', ActivityType.count + 1
    assert_select 'select#object_activity_type_id option[selected=selected]', 0
    
    assert_select 'h2', 'Manage Contacts'
    
    assert_select 'h3', 'Assigned Contacts'
    assert_select 'select#select_object_contacts[multiple=multiple]', 1
    assert_select 'select#select_object_contacts[multiple=multiple] option', 0
    
    assert_select "input[type=button][value=&lt; Add selected][onclick=?]", /addSelected\('contacts'\);/, :count => 1
    assert_select "input[type=button][value=&lt;&lt; Add all][onclick=?]", /addAll\('contacts'\);/, :count => 1
    assert_select "input[type=button][value=Remove selected &gt;][onclick=?]", /removeSelected\('contacts'\);/, :count => 1
    assert_select "input[type=button][value=Remove all &gt;&gt;][onclick=?]", /removeAll\('contacts'\);/, :count => 1
    
    assert_select 'h3', 'Other Contacts'
    assert_select 'select#select_other_contacts[multiple=multiple]', 1
    assert_select 'select#select_other_contacts[multiple=multiple] option', Contact.count
    assert_select 'select#select_other_contacts[multiple=multiple] option[selected=selected]', 0

    assert_select 'input[type=submit][onclick=selectAllOptions()][value=Create]', 1
    
    assert_select 'a[href=/activities/show]', 'Show', :count => 1
    assert_select 'a[href=/activities/list]', 'Back', :count => 1
  end

  def test_new__activity_type
    get :new, { :table_name => 'activity_types' }, { :user => 1 }
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:object)
    
    assert_select 'h1', 'New activity type'
    assert_select 'input#object_name[type=text]', 1
    
    assert_select 'h2', 'Manage Activities'
    
    assert_select 'h3', 'Assigned Activities'
    assert_select 'select#select_object_activities[multiple=multiple]', 1
    assert_select 'select#select_object_activities[multiple=multiple] option', 0
    
    assert_select "input[type=button][value=&lt; Add selected][onclick=?]", /addSelected\('activities'\);/, :count => 1
    assert_select "input[type=button][value=&lt;&lt; Add all][onclick=?]", /addAll\('activities'\);/, :count => 1
    assert_select "input[type=button][value=Remove selected &gt;][onclick=?]", /removeSelected\('activities'\);/, :count => 1
    assert_select "input[type=button][value=Remove all &gt;&gt;][onclick=?]", /removeAll\('activities'\);/, :count => 1
    
    assert_select 'h3', 'Other Activities'
    assert_select 'select#select_other_activities[multiple=multiple]', 1
    assert_select 'select#select_other_activities[multiple=multiple] option', Activity.count
    assert_select 'select#select_other_activities[multiple=multiple] option[selected=selected]', 0

    assert_select 'input[type=submit][onclick=selectAllOptions()][value=Create]', 1
    
    assert_select 'a[href=/activity_types/show]', 'Show', :count => 1
    assert_select 'a[href=/activity_types/list]', 'Back', :count => 1
  end  
  

  def test_create__activity
    count = Activity.count

    post :new, { :object => { :notes => 'AAA', :activity_type_id => '2', :contact_ids => ["1", "2"] }, :table_name => 'activities' }, { :user => 1 }

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal count + 1, Activity.count
    a = Activity.find_by_notes('AAA')
    assert_not_nil a
    assert_not_nil a.activity_type
    assert_equal 2, a.activity_type.id
    
    assert_not_nil a.contacts
    assert_equal 2, a.contacts.size
  end
  
  def test_create__activity_with_empty_associated
    count = Activity.count

    post :new, { :object => { :notes => 'AAA' }, :table_name => 'activities' }, { :user => 1 }

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal count + 1, Activity.count
    a = Activity.find_by_notes('AAA')
    assert_not_nil a
    assert_nil a.activity_type
    assert_not_nil a.contacts
    assert_equal 0, a.contacts.size
  end
  
  def test_create__activity_type
    count = ActivityType.count

    post :new, { :object => { :name => 'AAA', :activity_ids => ["1", "2"] }, :table_name => 'activity_types' }, { :user => 1 }

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal count + 1, ActivityType.count
    a = ActivityType.find_by_name('AAA')
    assert_not_nil a
    
    assert_not_nil a.activities
    assert_equal 2, a.activities.size
  end

  def test_create__activity_type_with_empty_associated
    count = ActivityType.count

    post :new, { :object => { :name => 'AAA', :activity_ids => [] }, :table_name => 'activity_types' }, { :user => 1 }

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal count + 1, ActivityType.count
    a = ActivityType.find_by_name('AAA')
    assert_not_nil a
    
    assert_not_nil a.activities
    assert_equal 0, a.activities.size
  end
  
  def test_edit__activity
    get :edit, { :id => activities(:renat_and_yura_call_out), :table_name => 'activities' }, { :user => 1 }

    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:object)
    
    assert_select 'h1', 'Editing activity'
    assert_select 'textarea#object_notes', 1
    assert_select 'select#object_activity_type_id', 1
    assert_select 'select#object_activity_type_id option', ActivityType.count + 1
    assert_select 'select#object_activity_type_id option[selected=selected]', { :text => 'Call out', :count => 1 }
    
    assert_select 'h2', 'Manage Contacts'
    
    assert_select 'h3', 'Assigned Contacts'
    assert_select 'select#select_object_contacts[multiple=multiple]', 1
    assert_select 'select#select_object_contacts[multiple=multiple] option', activities(:renat_and_yura_call_out).contacts.size
    assert_select 'select#select_object_contacts[multiple=multiple] option', 'Yury Kotlyarov'
    assert_select 'select#select_object_contacts[multiple=multiple] option', 'Renat Akhmerov'
    
    assert_select "input[type=button][value=&lt; Add selected][onclick=?]", /addSelected\('contacts'\);/, :count => 1
    assert_select "input[type=button][value=&lt;&lt; Add all][onclick=?]", /addAll\('contacts'\);/, :count => 1
    assert_select "input[type=button][value=Remove selected &gt;][onclick=?]", /removeSelected\('contacts'\);/, :count => 1
    assert_select "input[type=button][value=Remove all &gt;&gt;][onclick=?]", /removeAll\('contacts'\);/, :count => 1
    
    assert_select 'h3', 'Other Contacts'
    assert_select 'select#select_other_contacts[multiple=multiple]', 1
    assert_select 'select#select_other_contacts[multiple=multiple] option', Contact.count-activities(:renat_and_yura_call_out).contacts.size
    assert_select 'select#select_other_contacts[multiple=multiple] option[selected=selected]', 0

    assert_select 'input[type=submit][onclick=selectAllOptions()][value=Update]', 1
    
    assert_select 'a[href=/activities/show/1]', 'Show', :count => 1
    assert_select 'a[href=/activities/list]', 'Back', :count => 1
  end

  def test_edit__activity_with_no_activity_type_assigned
    get :edit, { :id => activities(:no_activity_type_assigned), :table_name => 'activities' }, { :user => 1 }

    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:object)
    
    assert_select 'h1', 'Editing activity'
    assert_select 'select#object_activity_type_id', 1
    assert_select 'select#object_activity_type_id option', ActivityType.count + 1
    assert_select 'select#object_activity_type_id option[selected=selected]', 0
    
    assert_select 'h3', 'Assigned Contacts'
    assert_select 'select#select_object_contacts[multiple=multiple]', 1
    assert_select 'select#select_object_contacts[multiple=multiple] option', 0
    
    assert_select 'h3', 'Other Contacts'
    assert_select 'select#select_other_contacts[multiple=multiple]', 1
    assert_select 'select#select_other_contacts[multiple=multiple] option', Contact.count
    assert_select 'select#select_other_contacts[multiple=multiple] option[selected=selected]', 0

    assert_select 'input[type=submit][onclick=selectAllOptions()][value=Update]', 1
    
    assert_select 'a[href=/activities/show/5]', 'Show', :count => 1
    assert_select 'a[href=/activities/list]', 'Back', :count => 1
  end

  def test_edit__activity_type
    get :edit, { :id => activity_types(:call_out).id, :table_name => 'activity_types' }, { :user => 1 }
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:object)
    
    assert_select 'h1', 'Editing activity type'
    assert_select 'input#object_name[type=text]', 1
    
    assert_select 'h2', 'Manage Activities'
    
    assert_select 'h3', 'Assigned Activities'
    assert_select 'select#select_object_activities[multiple=multiple]', 1
    assert_select 'select#select_object_activities[multiple=multiple] option', 2
    
    assert_select "input[type=button][value=&lt; Add selected][onclick=?]", /addSelected\('activities'\);/, :count => 1
    assert_select "input[type=button][value=&lt;&lt; Add all][onclick=?]", /addAll\('activities'\);/, :count => 1
    assert_select "input[type=button][value=Remove selected &gt;][onclick=?]", /removeSelected\('activities'\);/, :count => 1
    assert_select "input[type=button][value=Remove all &gt;&gt;][onclick=?]", /removeAll\('activities'\);/, :count => 1
    
    assert_select 'h3', 'Other Activities'
    assert_select 'select#select_other_activities[multiple=multiple]', 1
    assert_select 'select#select_other_activities[multiple=multiple] option', Activity.count-2
    assert_select 'select#select_other_activities[multiple=multiple] option[selected=selected]', 0

    assert_select 'input[type=submit][onclick=selectAllOptions()][value=Update]', 1
    
    assert_select 'a[href=/activity_types/show/4]', 'Show', :count => 1
    assert_select 'a[href=/activity_types/list]', 'Back', :count => 1
  end  
  
  def test_edit__activity_type_with_no_assigned_activities
    get :edit, { :id => activity_types(:no_assigned_activities).id, :table_name => 'activity_types' }, { :user => 1 }
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:object)
    
    assert_select 'h1', 'Editing activity type'
    assert_select 'input#object_name[type=text]', 1
    
    assert_select 'h3', 'Assigned Activities'
    assert_select 'select#select_object_activities[multiple=multiple]', 1
    assert_select 'select#select_object_activities[multiple=multiple] option', 0
    
    assert_select 'h3', 'Other Activities'
    assert_select 'select#select_other_activities[multiple=multiple]', 1
    assert_select 'select#select_other_activities[multiple=multiple] option', Activity.count
    assert_select 'select#select_other_activities[multiple=multiple] option[selected=selected]', 0

    assert_select 'input[type=submit][onclick=selectAllOptions()][value=Update]', 1
    
    assert_select 'a[href=/activity_types/show/7]', 'Show', :count => 1
    assert_select 'a[href=/activity_types/list]', 'Back', :count => 1
  end  
  
  def test_update__activities_with_empty_associated
    assert_equal 2, Activity.find(activities(:renat_and_yura_call_out).id).contacts.size
    assert_not_nil Activity.find(activities(:renat_and_yura_call_out).id).activity_type
    
    post :edit, { :id => activities(:renat_and_yura_call_out).id, 
      :object => { :notes => 'new notes', :activity_type_id => ''}, :table_name => 'activities' }, { :user => 1 }
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => activities(:renat_and_yura_call_out).id
    
    assert_equal 0, Activity.find(activities(:renat_and_yura_call_out).id).contacts.size
    assert_nil Activity.find(activities(:renat_and_yura_call_out).id).activity_type
  end

  def test_update__activities_with_different_associated
    assert_equal 2, Activity.find(activities(:renat_and_yura_call_out).id).contacts.size
    assert_not_nil Activity.find(activities(:renat_and_yura_call_out).id).activity_type
    assert_equal 4, Activity.find(activities(:renat_and_yura_call_out).id).activity_type.id
    
    post :edit, { :id => activities(:renat_and_yura_call_out).id, 
      :object => { :notes => 'new notes', :contact_ids => ["1", "3", "4"], :activity_type_id => '1'}, :table_name => 'activities' }, { :user => 1 }
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => activities(:renat_and_yura_call_out).id
    
    assert_equal 3, Activity.find(activities(:renat_and_yura_call_out).id).contacts.size
    assert_not_nil Activity.find(activities(:renat_and_yura_call_out).id).activity_type
    assert_equal 1, Activity.find(activities(:renat_and_yura_call_out).id).activity_type.id
  end

  def test_update__activity_types_with_empty_associated
    assert_equal 2, ActivityType.find(activity_types(:call_out).id).activities.size
    
    post :edit, { :id => activity_types(:call_out).id, 
      :object => { :name => 'Call blabla' }, :table_name => 'activity_types'}, { :user => 1 }
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => activity_types(:call_out).id
    
    assert_equal 0, ActivityType.find(activity_types(:call_out).id).activities.size
  end

  def test_update__activities_with_different_associated
    assert_equal 2, ActivityType.find(activity_types(:call_out).id).activities.size
    
    post :edit, { :id => activity_types(:call_out).id,
      :object => { :name => 'Call blabla', :activity_ids => ["2", "3", "1"] }, :table_name => 'activity_types' }, { :user => 1 }
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => activity_types(:call_out).id
    
    assert_equal 3, ActivityType.find(activity_types(:call_out).id).activities.size
  end

  def test_destroy
    assert_nothing_raised {
      Activity.find(activities(:renat_and_yura_call_out).id)
    }

    post :destroy, { :id => activities(:renat_and_yura_call_out).id, :table_name => 'activities' }, { :user => 1 }
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Activity.find(activities(:renat_and_yura_call_out).id)
    }
  end

  def test_list__for_contacts_search
    get :list, { :table_name => 'contacts' }, { :user => 1 }

    assert_response :success
    assert_template 'list'

    assert_select 'input#query', 1
    assert_select 'input[value=Search]', 1
  end

  def test_search_contacts
    Contact.rebuild_index
    post :search, { :table_name => 'contacts', :query => 'Renat' }, { :user => 1 }
    assert_response :success
    assert_template 'list'
    assert_select 'div', 'Found 1 contact'
    assert_select 'input#query[value=Renat]', 1
    assert_select 'input[value=Search]', 1
    assert_select 'tr', 2
    assert_select 'td', 'Renat'
    
    post :search, { :table_name => 'contacts', :query => '*e*' }, { :user => 1 }
    assert_response :success
    assert_template 'list'
    assert_select 'div', 'Found 3 contacts'
    assert_select 'input#query[value=*e*]', 1
    assert_select 'input[value=Search]', 1
    assert_select 'tr', 4
    
    post :search, { :table_name => 'contacts', :query => 'GGGGG' }, { :user => 1 }
    assert_response :success
    assert_template 'list'
    assert_select 'div', 'Found 0 contacts'
    assert_select 'input#query[value=GGGGG]', 1
    assert_select 'input[value=Search]', 1
    assert_select 'tr', 1
    
    post :search, { :table_name => 'contacts' }, { :user => 1 }
    assert_response :redirect
    assert_redirected_to :action => 'list'
  end
end
