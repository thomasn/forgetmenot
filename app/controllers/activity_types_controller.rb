class ActivityTypesController < ApplicationController
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
    @activity_type_pages, @activity_types = paginate :activity_types, :per_page => 10
  end

  def show
    @activity_type = ActivityType.find(params[:id])
  end

  def new
    @activity_type = ActivityType.new(params[:activity_type])
    if request.post? && @activity_type.save
      flash[:notice] = 'Activity type was successfully created.'
      redirect_to :action => 'list'
    end
  end

  def edit
    @activity_type = ActivityType.find(params[:id])
    if request.post? 
      # if there is no activity_type_ids params then we drop all ActivityTypes from the activity_type
      get_multiple_associations('ActivityType').each do |association|
        associated = (association.name.to_s.singularize + '_ids').to_sym
        params[:activity_type][associated] = [] if params[:activity_type][associated].nil?
      end
      if @activity_type.update_attributes(params[:activity_type])
        flash[:notice] = 'Activity type was successfully updated.'
        redirect_to :action => 'show', :id => @activity_type
      end
    end
  end

  def destroy
    ActivityType.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
