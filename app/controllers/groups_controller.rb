class GroupsController < ApplicationController
  layout 'forgetmenot'
  include ApplicationHelper

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
    @group = Group.new(params[:group])
    if request.post? && @group.save
      flash[:notice] = 'Group was successfully created.'
      redirect_to :action => 'list'
    end
  end

  def edit
    @group = Group.find(params[:id])
    if request.post? 
      # if there is no group_ids params then we drop all Groups from the group
      get_multiple_associations('Group').each do |association|
        associated = (association.name.to_s.singularize + '_ids').to_sym
        params[:group][associated] = [] if params[:group][associated].nil?
      end
      if @group.update_attributes(params[:group])
        flash[:notice] = 'Group was successfully updated.'
        redirect_to :action => 'show', :id => @group
      end
    end
  end

  def destroy
    Group.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
