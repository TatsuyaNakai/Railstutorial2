class SessionsController < ApplicationController
  def new
  end
  
  def create
    user=User.find_by(email:params[:session][:email].downcase)
    # form_withのemailでname属性に渡されたものをuserのアドレスで一致するインスタンスをuserに格納する。
    if user&.authenticate(params[:session][:password])
    # if user && user.authenticate(params[:session][:password])の省略形
    # authenticateは、has_secure_passwordをモデルに書いたら作られたメソッド（だからどこにも書かれてない。）
    # 引数の文字列がオブジェクトのパスワードと一致するか、
    # 一致すればオブジェクトを返す。間違うとfalseを返す。
      log_in user
      redirect_to user_url(user)
      
    else
      flash.now[:danger]= "Invalid email/password combination"
      render 'new'
    end
  end
  
  def destroy
    log_out
    redirect_to root_url
  end
  
end
