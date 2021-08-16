class AddIndexToUsersEmail < ActiveRecord::Migration[6.0]
  def change
     add_index :users, :email, unique: true
    # usersテーブルのemailカラムで一意性を強制する。
    # 保存する時にダブルクリックで２回データがとんでも大丈夫な状態にしてる。
    # dbに同じ名前のemailが2つ入れない。一意性をtrueにしてる。
    # add_indexで以降を追加してる。インデックスをつけることで膨大な量のデータを
    # 検索するのは早くなる。けど、読み込みが遅くなるので注意する。
  end
end
