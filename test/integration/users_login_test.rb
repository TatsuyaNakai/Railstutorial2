require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  
  def setup
    @user= users(:michael)
  end
  
  test "login with valid email/invalid password" do
    # 無効なパスワードを入力して、ログインを弾かれるシュミレート
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email:    @user.email,
                                          password: "invalid" } }
    assert_not is_logged_in?
    # false待ち。sessionがあるかどうか。
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
  
  test "login with valid information followed by logout" do
    # 有効な情報を入れて、レイアウトの移動の経過も確認するテスト
    get login_path
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
    assert is_logged_in?
    # true待ち。sessionがあればtrueを返す。
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    # false待ち。ログアウトしてるからsessionはない。ないなら、falseが返る。
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
  
end
