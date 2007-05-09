class ContactsController < ApplicationController
  
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
    @contact_pages, @contacts = paginate :contacts, :per_page => 10
  end

  def show
    @contact = Contact.find(params[:id])
  end

  def new
    @contact = Contact.new(params[:contact])
    if request.post? && @contact.save
      flash[:notice] = 'Contact was successfully created.'
      redirect_to :action => 'list'
    end
  end

  def edit
    @contact = Contact.find(params[:id])
    if request.post? 
      # if there is no contact_ids params then we drop all contacts from the group
      get_multiple_associations('Contact').each do |association|
        associated = (association.name.to_s.singularize + '_ids').to_sym
        params[:contact][associated] = [] if params[:contact][associated].nil?
      end
      if @contact.update_attributes(params[:contact])
        flash[:notice] = 'Contact was successfully updated.'
        redirect_to :action => 'show', :id => @contact
      end
    end
  end

  def destroy
    Contact.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
