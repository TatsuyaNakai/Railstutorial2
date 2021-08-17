ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # 特定のワーカーではテストをパラレル実行する
  parallelize(workers: :number_of_processors)

  # すべてのテストがアルファベット順に実行されるよう、
  #test/fixtures/*.ymlにあるすべてのfixtureをセットアップする
  fixtures :all
  include ApplicationHelper

  # （すべてのテストで使うその他のヘルパーメソッドは省略）
  
  def is_logged_in?
    !session[:user_id].nil?
    # ヘルパーはテスト環境から呼び出すことができない。
    # log_inが使えないから、sessionを代用して使う。
  end
  
end
