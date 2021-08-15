module ApplicationHelper
   # ページごとの完全なタイトルを返します。
  def full_title(page_title = '')
    # page_titleの引数は、デフォルトでは空白
    base_title = "Ruby on Rails Tutorial Sample App"
    if page_title.empty?
      # 引数が空白の場合
      base_title
    else
      page_title + " | " + base_title
    end
  end
end
