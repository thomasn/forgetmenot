class ActivitiesController < ApplicationController
  layout 'forgetmenot'
  
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
    @activity = Activity.new
  end

  def create
    @activity = Activity.new(params[:activity])
    if @activity.save
      flash[:notice] = 'Activity was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @activity = Activity.find(params[:id])
  end

  def update
    @activity = Activity.find(params[:id])
    # if there is no contact_ids params then we drop all contacts from the activity
    params[:activity][:contact_ids] = [] if params[:activity][:contact_ids].nil?
   
    if @activity.update_attributes(params[:activity])
      flash[:notice] = 'Activity was successfully updated.'
      redirect_to :action => 'show', :id => @activity
    else
      render :action => 'edit'
    end
  end

  def destroy
    Activity.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
