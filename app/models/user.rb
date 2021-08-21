class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email
  before_create :create_activation_digest
  
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name:   "Relationship",
                                  foreign_key:  "follower_id",
                                    dependent:  :destroy
                                    
  has_many :following, through: :active_relationships, source: :followed
  
  has_many :passive_relationships, class_name: "Relationship",
                                   foreign_key: "followed_id",
                                     dependent: :destroy
                                     
  has_many :followers, through: :passive_relationships, source: :follower
  
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

  validates :password, presence: true, length: {minimum: 6},allow_nil: true
  
  
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
  
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    # sendで引数においたハッシュのキーをメソッドとして扱う。
    # 今回の場合は、digest=〇〇_digestになる。
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
    
  end
  
  def forget
    update_attribute(:remember_digest, nil)
  end

  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end
  
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
    # 引数のアドレスにメールをすぐに送ること
  end
  
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end
  
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
    # 2時間以内を表現してる。
  end
  
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    # relationshipsテーブルのfollowed_idのカラムにおいて、
    # follower_idがuser_idのものをfollowing_idsに格納
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end
  
  # ユーザーをフォローする
  def follow(other_user)
    following << other_user
    # other_userをfollowingの配列の中に格納してる。（追加）
  end
  
   # ユーザーをフォロー解除する
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
    # テーブルから、該当するユーザーをidから探して削除する。
  end

  # 現在のユーザーがフォローしてたらtrueを返す
  def following?(other_user)
    following.include?(other_user)
    # 該当するユーザーが配列の中に入っているかを確認する。
  end



# ---------------------------------------------------------------------
  private
  
  def downcase_email
    self.email.downcase!
  end
  
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest= User.digest(activation_token)
    # dbが作成される前にカラムが作られる時は、dbが作成されたら自動的に代入するようになってる。
  end

end