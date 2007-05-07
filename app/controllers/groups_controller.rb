class GroupsController < ApplicationController
  layout 'forgetmenot'

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
  :redirect_to => { :action => :list }

  def list
    @group_pages, @groups = paginate :groups, :per_page => 10
  end

  def show
    @group = Group.find(params[:id])
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(params[:group])
    if @group.save
      flash[:notice] = 'Group was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @group = Group.find(params[:id])
    @group_contacts = @group.contacts.collect {|c| ["#{c.first_name} #{c.last_name}", c.id]}
    # other options will be used for select_tag. we need to pass string with options instead of array
    @other_contacts = @other_contacts = (Contact.find(:all)-@group.contacts).collect {|c| "<option value='#{c.id}'>#{c.first_name} #{c.last_name}</option>"}.join
  end

  def update
    @group = Group.find(params[:id])
    # if there is no contact_ids params then we drop all contacts from the group
    params[:group][:contact_ids] = [] if params[:group][:contact_ids].nil?
    if @group.update_attributes(params[:group])
      flash[:notice] = 'Group was successfully updated.'
      redirect_to :action => 'show', :id => @group
    else
      render :action => 'edit'
    end
  end

  def destroy
    Group.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
