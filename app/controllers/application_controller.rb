class ApplicationController < ActionController::Base
  include SessionsHelper
  
  private
  
    def logged_in_user
      unless logged_in?
        store_location
        # ここのページ（移ろうとした先のページ）をsession[:forwarding_url]に格納
        flash[:danger]="Please log in."
        redirect_to login_url
      end
    end
    
end
