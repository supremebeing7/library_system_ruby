require './lib/book'
require './lib/author'
require './lib/patron'
require 'pg'
require 'Date'

DB = PG.connect({:dbname => 'library_system'})

def main_menu
  system("clear")
  puts "'L' - Librarian"
  puts "'P' - Patron"
  choice = gets.chomp.upcase
  case choice
  when 'L'
    lib_menu
  when 'P'
    puts "Name:"
    name = gets.chomp
    current_patron = Patron.fetch_patron(name)
    patron_menu(current_patron)
  else
    puts "Invalid entry"
    main_menu
  end
end

def patron_menu(current_patron)
  system("clear")
  puts "'C' - Checkout Books"
  puts "'S' - Show All Books"
  puts "'H' - Show checkout history"
  choice = gets.chomp.upcase
  case choice
  when 'C'
    checkout(current_patron)
  when 'S'
    show_books_with_authors
  when 'H'
    show_checkout_history(current_patron)
  else
    puts "Invalid entry"
    patron_menu(current_patron)
  end
end

def checkout(current_patron)
  system("clear")
  Patron.available_books.each_with_index do |book, index|
    puts "#{index + 1}. #{book.title} - Copies available: #{book.qty}"
  end
  puts "Which book would you like to check out?"
  book_index = gets.chomp.to_i - 1
  book_title = Patron.available_books[book_index].title
  book_object = Book.fetch_book(book_title)
  Patron.change_copy(book_object, current_patron)
  puts "Checked out!"
  puts "Book due: #{current_patron.get_due_date}"
  patron_menu(current_patron)
end

def show_checkout_history(current_patron)
  system("clear")
  puts "Previous checkouts:"
  puts current_patron
  current_patron.patron_history.each do |checkout|
    puts "\t#{checkout['title']} - #{checkout['due_date']}"
  end
  patron_menu(current_patron)
end

def lib_menu
  system("clear")
  puts "'B' - Add Book"
  puts "'A' - Add Author"
  puts "'S' - Show All Books"
  puts "'O' - Show Overdue Books"
  choice = gets.chomp.upcase
  case choice
  when 'B'
    add_book
  when 'A'
    add_author
  when 'S'
    show_books_with_authors
  when 'O'
    show_overdue_books
  else
    puts "Invalid entry"
    sleep(1)
    lib_menu
  end
end

def add_book
  system("clear")
  puts "Enter the book title"
  book_title = gets.chomp.capitalize
  puts "Enter the category"
  category = gets.chomp
  puts "How many copies?"
  qty = gets.chomp.to_i
  new_book = Book.create({'title' => book_title, 'category' => category, 'qty' => qty})
  puts "Who is the author?"
  author = gets.chomp.capitalize
  new_author = Author.create({'name' => author})
  new_author.add_to_join_table(new_book.id, new_author.id)
  puts "#{book_title} (#{category}), by #{author} added!"
  sleep(2)
  main_menu
end

def add_author
  puts "Who is the author?"
  author = gets.chomp.capitalize
  new_author = Author.create({'name' => author})
  show_books
  puts "Which of these books did they write? Type '0' if none"
  book_id = gets.chomp.to_i
  book_title = Book.fetch_book(book_id)['title']
  category_name = Book.fetch_category(book_title)
  new_author.add_to_join_table(book_id, new_author.id)
  puts "#{book_title} (#{category_name}), by #{author} added!"
  sleep(2)
  main_menu
end

def show_books
  Book.all.each_with_index do |book, index|
    book_id = Book.fetch_book(book.title)['id']
    category_name = Book.fetch_category(book.title)
    puts "#{book_id}. #{book.title} -- (category: #{category_name})"
  end
end

def show_books_with_authors
  system "clear"
  Book.all.each_with_index do |book, index|
    book_id = Book.fetch_book(book.title)['id']
    authors = Author.fetch_authors(book_id)
    puts "#{index + 1}. #{book.title} -- (category: #{book.category})\n"
    authors.each do |author|
      puts "\t #{author}"
    end
    puts "\n"
  end
  puts "\nPress enter to return to the main menu"
  gets
  main_menu
end


def show_overdue_books
  system("clear")
  puts "OVERDUE BOOKS:"
  Book.overdue_books.each do |book|
    puts "\t#{book['name']} has '#{book['title']}' due: #{book['due_date']}"
  end
  puts "\nPress enter to return to the librarian menu"
  gets
  lib_menu
end

main_menu
