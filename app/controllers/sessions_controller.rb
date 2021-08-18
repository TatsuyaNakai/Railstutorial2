class SessionsController < ApplicationController
  def new
    
  end
  
  def create
    @user=User.find_by(email:params[:session][:email].downcase)
    # form_withのemailでname属性に渡されたものをuserのアドレスで一致するインスタンスをuserに格納する。
    if @user&& @user.authenticate(params[:session][:password])
    # if user && user.authenticate(params[:session][:password])の省略形
    # authenticateは、has_secure_passwordをモデルに書いたら作られたメソッド（だからどこにも書かれてない。）
    # 引数の文字列がオブジェクトのパスワードと一致するか、
    # 一致すればオブジェクトを返す。間違うとfalseを返す。
      log_in @user
      params[:session][:remember_me] == '1'? remember(@user): forget(@user)
      redirect_back_or(user_url(@user))
    else
      flash.now[:danger]= "Invalid email/password combination"
      render 'new'
    end
  end
  
  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
  
end
