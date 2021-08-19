require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  test "account_activation" do
    user = users(:michael)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)
    assert_equal "Account activation", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match user.name,               mail.body.encoded
    assert_match user.activation_token,   mail.body.encoded
    assert_match CGI.escape(user.email),  mail.body.encoded
  end
end

# encoredメソッド。本来の使い方は、引数を指定して、
# その引数を文字コードに変化するのが、使い方
# けど、テストの時は、期待値を文字コードとして認識する。

# 今回の場合でいうと、期待値を文字コードに変えたものがmailのbodyに
# あるか（一致するか）を検証してる。
