class CommonController < ApplicationController
  layout 'forgetmenot'
  include ApplicationHelper
  before_filter :login_required
  
  helper_method :entity_class_name
  helper_method :entity_class
  helper_method :entity_human_name

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy], :redirect_to => { :action => :list }

  def list
    options = { :per_page => 10 }
    if entity_class.hierarchical?
      options[:conditions] = ["parent_id = ? or id = ?", params[:parent_id], params[:parent_id]] unless params[:parent_id].nil?
      options[:order] = "root_id, lft"
    end
    @object_pages, @objects = paginate(params[:table_name].to_sym, options)
  end

  def show
    @object = entity_class.find(params[:id])
  end

  def new
    if entity_class.hierarchical? && !params[:object].nil? && params[:object][:parent_id].empty? && request.post?
      params[:object][:parent_id] = "0" 
      params[:object][:depth] = "0"
    end
    
    @object = entity_class.new(params[:object])
    if @object.respond_to?(:user_id)
      @object.user_id = session[:user]
    end
    
    if request.post? && @object.save
      flash[:notice] = "#{entity_human_name} was successfully created."
      redirect_to :action => 'list'
    end
  end

  def edit
    @object = entity_class.find(params[:id])
    if request.post?
      # if there is no contact_ids params then we drop all contacts from the group
      @object.get_multiple_associations.each do |association|
        associated = (association.name.to_s.singularize + '_ids').to_sym
        params[:object][associated] = [] if params[:object][associated].nil?
      end
      if @object.hierarchical?
        entity_class.find(params[:object].delete(:parent_id)).add_child(@object)
      end
      if @object.update_attributes(params[:object])
        flash[:notice] = "#{entity_human_name} was successfully updated."
        redirect_to :action => 'show', :id => @object
      end
    end
  end

  def destroy
    entity_class.find(params[:id]).destroy
    unless referer.nil?
      redirect_to request.env['HTTP_REFERER']
    else
      redirect_to :action => 'list'
    end
  end
  
  private 
  
  def entity_name
    params[:table_name].singularize
  end
  
  def entity_class_name
    entity_name.camelize
  end

  def entity_class
    entity_class_name.constantize
  end

  def entity_human_name
    entity_name.humanize
  end
  
end
