class EmailsController < ApplicationController
  skip_before_filter :authenticate_member!, :only => [:create]
  load_and_authorize_resource only: [:index, :show, :update]
  protect_from_forgery except: :create
  
  def index
    @emails = @emails.received.paginate(:per_page => 20, :page => params[:page])
  end
  
  def sent
    @emails = @emails.sent.paginate(:per_page => 20, :page => params[:page])
  end
  
  def show
  end
  
  def create
    request.headers["HTTP_AUTHORIZATION"]
    maildropConfig = YAML::load(File.read(Rails.root.join("config","cfg.cfg")))
    unless request.headers["HTTP_AUTHORIZATION"] == "Token token=\"#{maildropConfig[:mailboxes][0][:delivery_token]}\""
      raise CanCan::AccessDenied
    end
    
    mail = Mail.read_from_string(request.body.read)
    Email.create_from_mail(mail)
  end
  
  def update
  end
  
  def weekly
    @title = "Send Weekly Email"
    @eventdates = Eventdate.where(startdate: DateTime.current.beginning_of_day..(DateTime.current.beginning_of_day + 7.days))
  end
  
  def send_weekly
    @eventdates = Eventdate.where(startdate: DateTime.current.beginning_of_day..(DateTime.current.beginning_of_day + 7.days)).to_a
    @eventdates.select! { |eventdate| params["eventdate_include" + eventdate.id.to_s] == "1" }
    
    @eventdates.each do |eventdate|
      eventdate.email_description = params["eventdate_description" + eventdate.id.to_s]
      eventdate.save
    end
    
    EmailMailer.weekly_events(current_member, params[:to], params[:bcc], params[:subject], params[:intro_blurb], params[:outro_blurb], @eventdates).deliver_now
    
    flash[:notice] = "Email Sent"
    respond_to do |format|
      format.html {redirect_to weekly_email_index_url}
    end
  end
  
end