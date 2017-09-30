####################################################
####   THIS PAGE IS ONLY FOR SYNTAX REFERENCE   ####
####            - NOT USED IN APP -             ####
####            DELETE AFTER COMPLETION         ####
####################################################

####### collection actions below ############
=begin
get '/' do
  "Hello World"
  erb :'home/index'
end

# CONTACTS RESTful actions

# index
get '/contacts' do
  @contacts = Contact.all
  # will_paginate
  # 1/3) Create Instance Variable in Controller
  # 2/3) Iterate Instance Variable in erb: <% @wp_contacts.each do |contact| %>
  # 3/3) Include page menus at bottom of erb: <%= will_paginate @wp_contacts %>
  @wp_contacts = Contact.all.order("updated_at DESC").paginate(page: params[:page], per_page: 10)

  # @contacts.map{|contact| contact.email}.to_s ## (remove this)
  erb :'contacts/index'
end

# new
get '/contacts/new' do
  @contact = Contact.new  ## Prevents errors on Form Partial.
  erb :'contacts/new'
  # "This is the contacts new action."
end

# create
post '/contacts' do
  puts params
  @contact = Contact.create(params[:contact])
    if @contact.valid?
      redirect '/contacts'
    else
      status 422
      @errors = @contact.errors.full_messages
      erb :'contacts/new'
    end
  # redirect '/contacts'  ## Add this.
  # "This is the contacts create action." ## remove this.
end

####### member actions below ############

# show
get '/contacts/:id' do
  # "This is the contacts show action."
  # puts params ## (remove this)
  @contact = Contact.find(params[:id])
  # @contact.email ## (remove this)
  erb :'contacts/show'
end

# edit
get '/contacts/:id/edit' do
  @contact = Contact.find(params[:id])
  erb :'contacts/edit'
  # "This is the contacts edit action."
end

#### Update Method (patch or put) ####

def update_contact
  puts params
  @contact = Contact.find(params[:id])
  @contact.update(params[:contact])
  redirect "/contacts/#{@contact.id}"
end


# update - patch
patch '/contacts/:id' do
  update_contact
  # puts params
  # @contact = Contact.find(params[:id])
  # @contact.update(params[:contact])
  # redirect "/contacts/#{@contact.id}"
  # "This is the contacts update action."
end

# update - put
put '/contacts/:id' do
  update_contact
  # "This is the contacts update action."
end

# delete
delete '/contacts/:id' do
  Contact.find(params[:id]).destroy!
  redirect '/contacts'
  # "This is the contacts delete action."
end

=end
