class ActivitiesController < ApplicationController
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
    @activity_pages, @activities = paginate :activities, :per_page => 10
  end

  def show
    @activity = Activity.find(params[:id])
  end

  def new
    @activity = Activity.new(params[:activity])
    if request.post? && @activity.save
      flash[:notice] = 'Activity was successfully created.'
      redirect_to :action => 'list'
    end
  end

  def edit
    @activity = Activity.find(params[:id])
    if request.post? 
      # if there is no activity_ids params then we drop all Activities from the activity
      get_multiple_associations('Activity').each do |association|
        associated = (association.name.to_s.singularize + '_ids').to_sym
        params[:activity][associated] = [] if params[:activity][associated].nil?
      end
      if @activity.update_attributes(params[:activity])
        flash[:notice] = 'Activity was successfully updated.'
        redirect_to :action => 'show', :id => @activity
      end
    end
  end

  def destroy
    Activity.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
