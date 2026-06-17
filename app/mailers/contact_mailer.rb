class ContactMailer < ApplicationMailer
  def enquiry_notification(enquiry)
    @enquiry = enquiry

    mail(
      to: "kalainteriorsanddecor@gmail.com",
      reply_to: enquiry[:email].presence || "kalainteriorsanddecor@gmail.com",
      subject: "New Enquiry from #{enquiry[:name]} — Kala Interiors & Decor"
    )
  end
end
