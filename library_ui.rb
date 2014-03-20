require './lib/book'
require './lib/author'
require 'pg'

DB = PG.connect({:dbname => 'library_system'})

def main_menu
  puts "'L' - Librarian"
  puts "'P' - Patron"
  choice = gets.chomp.upcase
  case choice
  when 'L'
    lib_menu
  when 'P'
    puts "Name:"
    Patron.create({'name' => gets.chomp})
    patron_menu
  else
    puts "Invalid entry"
    main_menu
  end
end

def patron_menu
  puts "'C' - Checkout Books"
  puts "'S' - Show All Books"
  choice = gets.chomp.upcase
  case choice
  when 'C'
    checkout
  when 'S'
    show_books_with_authors
  else
    puts "Invalid entry"
    patron_menu
  end
end

def checkout
  Patron.available_books.each_with_index do |book, index|
    puts "#{index + 1}. #{book.title}"
  end
  puts "Which book would you like to check out?"
  book_index = gets.chomp.to_i - 1
  book_title = Patron.available_books[book_index].title
  book_id = Book.fetch_book(book_title)
  Patron.change_copy(book_id) #NOTE SURE IF THIS WORKS YET
  # UPDATE CHECKOUTS TABLE ALSO
  puts "Checked out!"
  patron_menu
end

def lib_menu
  puts "'B' - Add Book"
  puts "'A' - Add Author"
  puts "'S' - Show All Books"
  choice = gets.chomp.upcase
  case choice
  when 'B'
    add_book
  when 'A'
    add_author
  when 'S'
    show_books_with_authors
  else
    puts "Invalid entry"
    lib_menu
  end
end

def add_book
  puts "Enter the book title"
  book_title = gets.chomp
  puts "Enter the category"
  category = gets.chomp
  put "How many copies?"
  qty = gets.chomp.to_i
  new_book = Book.create({'title' => book_title, 'category' => category, 'qty' => qty})
  puts "Who is the author?"
  author = gets.chomp
  new_author = Author.create({'name' => author})
  new_author.add_to_join_table(new_book.id, new_author.id)
  puts "#{book_title}, by #{author} added!"
  main_menu
end

def add_author
  # book_index_hash = {}
  puts "Who is the author?"
  author = gets.chomp
  new_author = Author.create({'name' => author})
  show_books
  puts "Which of these books did they write? Type '0' if none"
  book_id = gets.chomp.to_i
  book_title = Book.fetch_book(book_id)['title']
  new_author.add_to_join_table(book_id, new_author.id)
  puts "#{book_title}, by #{author} added!"
  main_menu
end

def show_books
  Book.all.each_with_index do |book, index|
    book_id = Book.fetch_book(book.title)['id']
    puts "#{book_id}. #{book.title}"
  end
end

def show_books_with_authors
  Book.all.each_with_index do |book, index|
    book_id = Book.fetch_book(book.title)['id']
    authors = Author.fetch_authors(book_id)
    puts "#{index + 1} #{book.title}\n"
    authors.each do |author|
      puts "\t #{author}"
    end
    puts "\n"
  end
  main_menu
end

main_menu
