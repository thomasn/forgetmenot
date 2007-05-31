class CommonController < ApplicationController
  layout 'forgetmenot'
  include ApplicationHelper
  before_filter :login_required
  
  helper_method :entity_class_name
  helper_method :entity_class
  helper_method :entity_human_name

  OBJECTS_PER_PAGE = 10
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy ], :redirect_to => { :action => :list }

  def list
    if params[:tag]
      page = (params[:page] ||= 1).to_i
      offset = (page - 1) * OBJECTS_PER_PAGE

      objects = entity_class.find_tagged_with(params[:tag])
      @object_pages = Paginator.new(self, objects.size, OBJECTS_PER_PAGE, page)
      @objects = objects[offset...(offset + OBJECTS_PER_PAGE)]
    else
      options = { :per_page => OBJECTS_PER_PAGE }
      if entity_class.hierarchical?
        options[:conditions] = ["parent_id = ? or id = ?", params[:parent_id], params[:parent_id]] unless params[:parent_id].nil?
        options[:order] = "root_id, lft"
      end
      @object_pages, @objects = paginate(params[:table_name].to_sym, options)
    end
  end

  def search
    if params[:query].nil? || params[:query].strip.empty?
      redirect_to :action => 'list'
      return
    end
     
    page = (params[:page] ||= 1).to_i
    
    offset = (page - 1) * OBJECTS_PER_PAGE

    @objects = entity_class.find_by_contents(params[:query], { :offset => offset, :limit => OBJECTS_PER_PAGE })
    @object_pages = Paginator.new(self, @objects.total_hits, OBJECTS_PER_PAGE, page)

    render :action => 'list'
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
      if @object.hierarchical? && !params[:object][:parent_id]
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
  
  def prepare_email
    if params[:contact_ids].nil? || params[:contact_ids].empty?
      flash[:notice] = 'Please check contacts you\'d like to send an email to'
      redirect_to :action => 'list'
      return
    end
    @contact_ids = params[:contact_ids]
    @email_message = EmailMessage.new
    @to = Contact.find(params[:contact_ids], :order => 'email').collect { |c| c.email }.join(', ')
  end
  
  def send_email
    params[:activity] = { :user_id => session[:user] }
    params[:activity][:activity_type_id] = ActivityType.find_or_create_by_name('Email out').id
    params[:activity][:contact_ids] = params[:contact_ids]
    activity = Activity.create(params[:activity])

    params[:email_message][:activity_id] = activity.id
    email_message = EmailMessage.create(params[:email_message])
    email = ContactMailer.create_email(email_message)
    ContactMailer.deliver(email)
    
    flash[:notice] = "The message was successfully sent to #{email_message.activity.contacts.collect { |c| c.email }.join(', ')}."
    redirect_to :action => 'list'
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
