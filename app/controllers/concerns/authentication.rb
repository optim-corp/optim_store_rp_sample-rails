module Concerns
  module Authentication
    def self.included(klass)
      klass.send :helper_method, :current_user, :authenticated?
      klass.send :before_action, :optional_authentication
    end

    def authenticated?
      !current_user.blank?
    end

    def current_user
      @current_user
    end

    def optional_authentication
      if session[:current_user]
        authenticate User.find_by(id: session[:current_user])
      end
    rescue ActiveRecord::RecordNotFound
      unauthenticate!
    end

    def require_anonymous_access
      if authenticated?
        redirect_to root_url
      end
    end

    def require_authentication
      unless authenticated?
        redirect_to root_url
      end
    end

    def authenticate(user)
      if user
        @current_user = user
        session[:current_user] = user.id
      end
    end

    def unauthenticate!
      @current_user = session[:current_user] = nil
    end
  end
end