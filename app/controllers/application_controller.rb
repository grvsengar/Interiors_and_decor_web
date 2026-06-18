class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from ActionController::InvalidAuthenticityToken do
    flash[:error] = "Your session expired. Please try submitting the form again."
    redirect_back fallback_location: root_path
  end
end
