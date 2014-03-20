class Patron
  attr_reader :name, :id

  def initialize(attributes)
    @name = attributes['name']
  end

  def self.create(attributes)
    new_patron = Patron.new(attributes)
    new_patron.save
    new_patron
  end

  def save
    result = DB.exec("INSERT INTO patrons (name) VALUES ('#{name}') RETURNING id;")
    @id = result.first['id'].to_i
  end

  def self.all
    results = DB.exec("SELECT * FROM patrons")
    all_patrons = []
    results.each do |result|
      all_patrons << Patron.new(result)
    end
    all_patrons
  end

  def self.available_books
    results = DB.exec("SELECT * FROM books WHERE quantity > 0;")
    available_books = []
    results.each do |result|
      available_books << Book.new(result)
    end
    available_books
  end

  def self.change_copy(book_id)
    results = DB.exec("SELECT * FROM copies WHERE book_id = #{book_id} AND checked_out = 0;")
    first_match = results.first['id']
    DB.exec("UPDATE copies SET checked_out = 1 WHERE id = #{first_match};")
  end
end
