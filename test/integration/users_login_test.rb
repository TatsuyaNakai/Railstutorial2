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
    get login_path
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    
    # 2番目のウィンドウでログアウトをクリックするユーザーをシミュレートする
    delete logout_path
    # ログアウトボタンを押すと、、
    follow_redirect!
    assert_select "a[href=?]", login_path
    # login_pathがはいったaタグはありますよね。
    assert_select "a[href=?]", logout_path,      count: 0
    # logout_pathが入ったaタグは０個ですよね。
    assert_select "a[href=?]", user_path(@user), count: 0
    # @userへのuser_pathが入ったaタグは０個ですよね。
    
    # ログインボタンがあって、ログアウトのボタンがなくて、ユーザーページにいけるのもない。
    # →ログインが解消されてますよね？ってことを聞きたい。
  end
  
  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    # rememberを実行する。
    assert_equal cookies[:remember_token], assigns(:user).remember_token
    # assert_not_emptyは、オブジェクト.empty?がfalseの時に通過する。（何かあれば通過）
  end

  test "login without remembering" do
    # cookieを保存してログイン
    log_in_as(@user, remember_me: '1')
    delete logout_path
    # cookieを削除してログイン
    log_in_as(@user, remember_me: '0')
    assert_empty cookies[:remember_token]
  end
  
end
