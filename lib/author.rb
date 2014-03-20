class Author
  attr_reader :id, :name

  def initialize(attributes)
    @name = attributes['name']
  end

  def self.create(attributes)
    new_author = Author.new(attributes)
    new_author.save
    new_author
  end

  def save
    result = DB.exec("INSERT INTO authors (name) VALUES ('#{name}') RETURNING id;")
    @id = result.first['id'].to_i
  end

  def self.all
    results = DB.exec("SELECT * FROM authors")
    all_authors = []
    results.each do |result|
      all_authors << Author.new(result)
    end
    all_authors
  end

  def add_to_join_table(book_id, author_id)
    DB.exec("INSERT INTO books_authors (book_id, author_id) VALUES (#{book_id}, #{author_id});")
  end

  def self.fetch_authors(book_id)
    authors = []
    results = DB.exec("SELECT * FROM books_authors JOIN authors ON (books_authors.author_id = authors.id) WHERE book_id = #{book_id};")
    results.each do |result|
      authors << result['name']
    end
    authors
  end
end
