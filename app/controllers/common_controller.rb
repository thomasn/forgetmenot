# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

class CommonController < ApplicationController
  layout 'forgetmenot'
  include ApplicationHelper
  before_filter :login_required
  before_filter :load_dynamic_attributes, :only => [ :index, :list, :search, :show, :new, :edit ]

  helper_method :entity_class_name
  helper_method :entity_class
  helper_method :entity_human_name

  OBJECTS_PER_PAGE = 250 if not defined? OBJECTS_PER_PAGE

  def index
    list
    render :action => 'list'
  end
  
  def index_test
    @attr = DynamicAttribute.find(:all)
    
  end
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy ], :redirect_to => { :action => :list }

  def list
    if params[:tag]
      page = (params[:page] ||= 1).to_i
      # offset = (page - 1) * OBJECTS_PER_PAGE

      # Find all objects from class with given tag
      objects = entity_class.find_tagged_with(params[:tag])
      @objects = objects.paginate(:pages =>page, :per_page => OBJECTS_PER_PAGE)
      
      # Old paginator -- DEPRICATED as of Rails 2 --
      # @object_pages = Paginator.new(self, objects.size, OBJECTS_PER_PAGE, page)
      # @objects = objects[offset...(offset + OBJECTS_PER_PAGE)]
    else
      options = { :per_page => OBJECTS_PER_PAGE }
      if entity_class.hierarchical?
        options[:conditions] = ["parent_id = ? or id = ?", params[:parent_id], params[:parent_id]] unless params[:parent_id].nil?
        options[:order] = "root_id, lft"
      end
      # Using will_paginate plugin
      @objects = entity_class.paginate(:page => params[:page], :per_page => OBJECTS_PER_PAGE)
    end
  end

  def search
    if params[:query].nil? || params[:query].strip.empty?
      redirect_to :action => 'list'
      return
    end

    if params[:table_name] != 'contacts'
      @objects = []
      return
    end
    page = (params[:page] ||= 1).to_i

    @objects = Contact.search(params[:query], :match_mode => :extended, :page => params[:page], :per_page => OBJECTS_PER_PAGE)

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

    create_associated

    if request.post?
      entity_class.transaction do
        save_associated
        @object.save!
        flash[:notice] = "#{entity_human_name} was successfully created."
        redirect_to :action => 'new'
      end
    end
  end

  def edit
    @object = entity_class.find(params[:id])
    create_associated

    if request.post?
      # if there is no contact_ids params then we drop all contacts from the group
      @object.get_multiple_associations.each do |association|
        associated = (association.name.to_s.singularize + '_ids').to_sym
        params[:object][associated] = [] if params[:object][associated].nil?
      end
      if @object.hierarchical? && !params[:object][:parent_id]
        entity_class.find(params[:object].delete(:parent_id)).add_child(@object)
      end

      entity_class.transaction do
        save_associated

        if @object.update_attributes(params[:object])
          flash[:notice] = "#{entity_human_name} was successfully updated."
          redirect_to :action => 'show', :id => @object
        end
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
    email_message.activity.contacts.each { |c|
      email = ContactMailer.create_email(email_message, c.email)
      ContactMailer.deliver(email)
    }

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

  def load_dynamic_attributes
    @dynamic_attributes = params[:table_name] == 'contacts' ? DynamicAttribute.find(:all) : []
  end

  def create_associated
    if params[:table_name] == 'contacts'
      @address = Address.new(params[:address])
      @address2 = Address.new(params[:address2])
    end
    if params[:table_name] == 'groups'
      @billing_address = Address.new(params[:billing_address])
      @shipping_address = Address.new(params[:shipping_address])
    end
  end

  def save_associated
    if params[:table_name] == 'contacts'
      logger.debug "========= address: #{@address.inspect}"
      logger.debug "========= address2: #{@address2.inspect}"
      if params[:address_radio] == 'create_new_address'
        unless empty_object?(@address)
          @object.address = @address
          @address.save!
        end
      end
      if params[:address2_radio] == 'create_new_address2'
        unless empty_object?(@address2)
          @object.address2 = @address2
          @address2.save!
        end
      end
    end

    if params[:table_name] == 'groups'
      if params[:billing_address_radio] == 'create_new_billing_address'
        unless empty_object?(@billing_address)
          @object.billing_address = @billing_address
          @billing_address.save!
        end
      end
      if params[:shipping_address_radio] == 'create_new_shipping_address'
        unless empty_object?(@shipping_address)
          @object.shipping_address = @shipping_address
          @shipping_address.save!
        end
      end
    end
  end

  def empty_object?(obj)
    obj.attributes.values.select { |a| !a.empty? }.compact.empty?
  end
end
