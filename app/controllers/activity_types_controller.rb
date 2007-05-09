class ActivityTypesController < ApplicationController
  layout 'forgetmenot'
  
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
    @activity_type = ActivityType.new
  end

  def create
    @activity_type = ActivityType.new(params[:activity_type])
    if @activity_type.save
      flash[:notice] = 'ActivityType was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @activity_type = ActivityType.find(params[:id])
  end

  def update
    @activity_type = ActivityType.find(params[:id])
    if @activity_type.update_attributes(params[:activity_type])
      flash[:notice] = 'ActivityType was successfully updated.'
      redirect_to :action => 'show', :id => @activity_type
    else
      render :action => 'edit'
    end
  end

  def destroy
    ActivityType.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
