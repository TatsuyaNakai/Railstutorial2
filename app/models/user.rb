class User < ApplicationRecord
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
  # passwordとpassword_digestカラムが使えるようになる。
  # 引数の文字列がオブジェクトのパスワードと一致するか確認できる
  # authenticateメソッドが使えるようになる。→合致したらobjを返す、違うならfalse

  validates :password, presence: true, length: {minimum: 6}
  
end
