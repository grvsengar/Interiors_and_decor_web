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

    # Log the enquiry to Rails log (swap for email/DB later)
    Rails.logger.info "[KALA ENQUIRY] Name: #{name} | Phone: #{phone} | Email: #{email} | Service: #{service} | City: #{city} | Budget: #{budget} | Message: #{message}"

    flash[:notice] = "Thank you #{name}! We've received your enquiry and will call you within 24 hours."
    redirect_to contact_path
  end
end
