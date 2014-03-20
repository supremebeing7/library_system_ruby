class Patron
  attr_reader :name, :id

  def initialize(attributes)
    @name = attributes['name']
    @id = attributes['id']
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
    results = DB.exec("SELECT * FROM books WHERE qty > 0;")
    available_books = []
    results.each do |result|
      available_books << Book.new(result)
    end
    available_books
  end

  def self.change_copy(book, current_patron)
    today = Date.today
    due_date = (today+21).to_s
    results = DB.exec("SELECT * FROM copies WHERE book_id = #{book['id'].to_i} AND checked_out = '0';")
    first_match = results.first['id']
    DB.exec("UPDATE copies SET checked_out = '1' WHERE id = #{first_match};")
    DB.exec("INSERT INTO checkouts (copy_id, patron_id, due_date) VALUES (#{first_match}, #{current_patron.id}, '#{due_date}');")
    DB.exec("UPDATE books SET qty = qty - 1 WHERE id = #{book['id'].to_i};")
  end

  def get_due_date
    results = DB.exec("SELECT due_date FROM checkouts WHERE patron_id = #{self.id} ORDER BY due_date DESC;")
    due_date = results.first['due_date']
  end

  def self.fetch_patron(name)
    results = DB.exec("SELECT * FROM patrons WHERE name = '#{name}';")
    if results.first == nil
      patron_results = DB.exec("INSERT INTO patrons (name) VALUES ('#{name}') RETURNING id;")
      patron = Patron.create(patron_results.first)
    else
      patron = Patron.new(results.first)
    end
    patron
  end

  def patron_history
    results = DB.exec("SELECT * FROM checkouts
      JOIN copies ON (checkouts.copy_id = copies.id)
      JOIN books ON (copies.book_id = books.id)
      WHERE patron_id = '#{self.id}';")
    checkouts = []
    results.each do |result|
      hash = {}
      hash["title"] = result['title']
      hash["due_date"] = result['due_date']
      checkouts << hash
    end
    checkouts
  end

end
