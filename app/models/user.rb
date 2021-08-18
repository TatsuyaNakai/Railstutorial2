class User < ApplicationRecord
  attr_accessor :remember_token
  
  before_save {self.email=self.email.downcase}
  # dbに保存するまえ、user=User.newで.user.saveするまえにブロック内が発火する。
  validates :name,  presence:true, length: {maximum: 50}
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence:true,
                    length: {maximum: 255},
                    format: {with:VALID_EMAIL_REGEX},
                    uniqueness: true
                    # uniquness: trueだと、大文字と小文字を区別する。
                    # その抜け目を埋めるためにbefore_saveでdbに保存する前。小文字に変換する。
  
  has_secure_password
  # ハッシュ化したパスワードをpassword_digestに保存できるようになる。
  # passwordとpassword_digestカラムが使えるようになる。（dbに保存してない。）
  # 引数の文字列がオブジェクトのパスワードと一致するか確認できる
  # authenticateメソッドが使えるようになる。→合致したらobjを返す、違うならfalse

  validates :password, presence: true, length: {minimum: 6}
  
  
  # # # クラスメソッドの知識について
  # 普通は、クラス内に書かれてるクラス名を持たないメソッドは、
  # インスタンスメソッドって言われる分類にはいる。
  # でも、クラス名を明記してメソッド名を書くと、
  # クラスメソッドと言われるものになる。
  # これは、インスタンスを作成しなくても、User.メソッドで実行できる。
  
   # 渡された文字列のハッシュ値を返す
   # もともとは、user.ymlのために作成したもの。has_secure_passwordを
   # テスト環境でやりたかったから。
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
    # BCryptのパスワードクラスでコストは状況によるけど、
    # 引数の文字列をハッシュ化する。
  end
  
  def User.new_token
    SecureRandom.urlsafe_base64
    # urlのエスケープにも対応してるランダムな22文字を返す。
  end
  
  def remember
    self.remember_token=User.new_token
    # selfで、User自身に紐づけることで、以下のremember_tokenは
    # クラスメソッドで定義されてるけど、使うことができるようになる。
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  def authenticated?(remember_token)
    # このremember_tokenは引数として、別にhogeとかでもいい、笑
    return false if remember_digest.nil?
    # ブラウザごとにcookiesは保存されるけど、remember_digestはdbに保存されるから、共通で確認できる。
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
    # newは、remember_digestと、引数に持ってこられたremember_tokenを
    # ハッシュ化される前の比較できる状態にして比較してる。一致したらtrueを返す。
  end
  
  def forget
    update_attribute(:remember_digest, nil)
  end
  
end
