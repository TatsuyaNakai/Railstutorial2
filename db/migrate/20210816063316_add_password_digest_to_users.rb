class AddPasswordDigestToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :password_digest, :string
    # usersテーブルに追加してる。password_digestカラムを、型は文字列
  end
end
