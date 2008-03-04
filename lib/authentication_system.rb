module AuthenticationSystem
	protected
	def require_login
		@current_user = User.find(session[:user_id]) if session[:user_id]
		respond_to do |format|
			format.html { 
				login_by_token unless logged_in?
				login_by_html  unless logged_in?
			}
			format.xml { login_by_basic_auth }
		end
	end

	# Na navegacao por html, o login é feito diretamente no controller. Este método
	# apenas verifica se o usuário já está logado ou não. Caso não esteja, ele é redirecionado.
	def login_by_html
		if !logged_in?
			flash[:warning] = 'You must be logged in to access this section of the site'[:login_required]
			session[:return_to] = request.request_uri
			redirect_to :controller => 'users', :action => 'login'
		end
	end

	def login_by_basic_auth
		authenticate_or_request_with_http_basic do |user_name, password| 
			@current_user = User.find_by_login_and_pass(user_name, password)
		end
	end

	def login_by_token
		user = User.find_by_id_and_login_key(*cookies[:login_token].split(";")) if cookies[:login_token]
		if !user.nil?
			setup_session(user, true)
			user.update_attribute(:last_seen, Time.now.utc)
		end
	end

	def setup_session(user, create_token = false)
		@current_user = user
		session[:user_id] = user.id
		session[:topics] = session[:forums] = {}
	  	cookies[:login_token] = {
			:value => "#{user.id};#{user.reset_login_key!}",
			:expires => 1.month.from_now.utc
		} if create_token
	end
	
	def destroy_session
		session.delete
		cookies.delete :login_token
	end

	def redirect_to_stored
		return_to = session[:return_to]

		if return_to
			session[:return_to] = nil
			redirect_to return_to
		else
			redirect_to dashboard_url
		end
	end

	def logged_in?
		!@current_user.nil?
	end

	def admin?
		logged_in? and @current_user.admin?
	end
end

class AccessDenied < Exception
end

