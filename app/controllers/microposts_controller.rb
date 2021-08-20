class MicropostsController < ApplicationController
    before_action :logged_in_user,  only: [:create, :destroy]
    before_action :correct_user,    only: [:destroy]
    
  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      #  エラーが起きた時に、上を取得しとかないと、ビューで表示できなくてエラーになる。
      render 'static_pages/home'
    end
  end
  
  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    redirect_to request.referrer || root_url
    # request.referrer  destroyのアクショに移るまえのビューに向かう。
  end
  
  
  
#   -------------------------------------
  private

    def micropost_params
      params.require(:micropost).permit(:content, :image)
    end
    
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      # ログインしてるユーザーのマイクロポストにidがURLと対応するものはあるか。
      redirect_to root_url if @micropost.nil?
    end
    
end
