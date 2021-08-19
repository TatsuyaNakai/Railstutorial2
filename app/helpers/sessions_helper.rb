# ここで定義したものはapplicationControllerでincludeされてるから、
# どこのコントローラでも使うことができる。

module SessionsHelper
  def log_in(user)
    session[:user_id]=user.id
  end
  
  def remember(user)
    user.remember
    # remember_digestにremember_tokenをハッシュ化した値を格納した。
    cookies.permanent.signed[:user_id] = user.id
    # 暗号化して、20年保存するcookiesのuser_idってキーにuser_idを格納
    cookies.permanent[:remember_token] = user.remember_token
    # 20年間保存するcookiesのremember_tokenってキーにuser.remember_tokenを格納
  end
  
  def current_user
    if(user_id= session[:user_id])
  # sessionをuser_idに代入する。なければnilでfalse、あればuser_idに値が入る。
      @current_user ||=User.find_by(id: user_id)
  # 上で定義したuser_idの番号を@current_userに代入する。
    elsif(user_id= cookies.signed[:user_id])
  # sessionがなかったら、次はcookiesにいきます。
  # cookiesをuser_idに保存する。なければnilでfalse、あればuser_idに値が入る。
      user= User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
  # user.rbのauthenticated?参照。digestの値と一致するかどうかを判断してる。
        log_in user
  # sessionに格納します。
        @current_user= user
      end
    end
  end
  
  def logged_in?
    !current_user.nil?
    # 直観的にわかりやすいから、nilならfalseを返す
  end
  
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user=nil
  end
  
  def current_user?(user)
    user && user == current_user
  end
  
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    # sessionハッシュでforwarding_urlが定義されてたら、そっちに飛ぶ。
    session.delete(:forwarding_url)
    # session[:forwarding_url]を消す。
  end
  
  def store_location
    session[:forwarding_url]= request.original_url if request.get?
    # HTTPメソッドがgetなら、最後に要求されたURLをsessionに代入する。
  end
  
end

