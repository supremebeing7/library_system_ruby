class Book
  attr_reader :title, :category, :category_id, :id, :qty

  def initialize(attributes)
    @title = attributes['title']
    @category = attributes['category']
    @category_id = Book.fetch_category_id(@category)
    @qty = attributes['qty']
  end

  def self.create(attributes)
    new_book = Book.new(attributes)
    new_book.save
    new_book
  end

  def save
    result = DB.exec("INSERT INTO books (title, category_id, qty) VALUES ('#{title}','#{category_id}', '#{qty}') RETURNING id;")
    @id = result.first['id'].to_i
    @qty.times do
      DB.exec("INSERT INTO copies (book_id, checked_out) VALUES (#{id}, 0);")
    end
  end

  def self.all
    results = DB.exec("SELECT * FROM books")
    all_books = []
    results.each do |result|
      all_books << Book.new(result)
    end
    all_books
  end

  def self.fetch_category_id(category)
    results = DB.exec("SELECT * FROM category WHERE name = '#{category}';")
    if results.first == nil
      cat_results = DB.exec("INSERT INTO category (name) VALUES ('#{category}') RETURNING id;")
      category_num = cat_results.first['id']
    else
      category_num = results.first['id']
    end
    category_num
  end


  def self.fetch_book(book_detail)
    if book_detail.is_a? Integer
      result = DB.exec("SELECT * FROM books WHERE id = '#{book_detail}';")
    else
      result = DB.exec("SELECT * FROM books WHERE title = '#{book_detail}';")
    end
    book_object = result.first
  end
end
