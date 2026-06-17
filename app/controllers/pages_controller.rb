class PagesController < ApplicationController
  def home
  end

  def services
  end

  def portfolio
  end

  def about
  end

  def contact
  end

  def submit_contact
    name    = params[:name].to_s.strip
    phone   = params[:phone].to_s.strip
    email   = params[:email].to_s.strip
    service = params[:service].to_s.strip
    city    = params[:city].to_s.strip
    budget  = params[:budget].to_s.strip
    message = params[:message].to_s.strip

    if name.blank? || phone.blank? || message.blank?
      flash[:error] = "Please fill in your name, phone number, and message."
      redirect_to contact_path and return
    end

    enquiry = {
      name: name, phone: phone, email: email,
      service: service, city: city, budget: budget, message: message
    }

    # Always log as backup
    Rails.logger.info "[KALA ENQUIRY] #{enquiry.inspect}"

    # Send email notification
    begin
      ContactMailer.enquiry_notification(enquiry).deliver_now
    rescue => e
      Rails.logger.error "[KALA MAILER ERROR] #{e.message}"
    end

    flash[:notice] = "Thank you #{name}! We've received your enquiry and will get back to you within 24 hours."
    redirect_to contact_path
  end
end
