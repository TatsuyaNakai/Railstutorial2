class UsersController < ApplicationController
  
  def show
    @user= User.find(params[:id])
    
  end
  
  def new
    @user=User.new
  end
  
  def create
    @user=User.new(user_params)
    if @user.save
      log_in @user
      flash[:success]= "Welcome to the Sample App!"
      # 次のページ１回だけ表示されるものを格納してる。
      redirect_to user_url(@user)
      # user_urlは省略できる。
    else
      render 'new'
    end
  end
  
  
  
  
  # ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
  private
  
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
      # strong paramsで許可したものだけ更新できるようにしてる。
    end
  
end
