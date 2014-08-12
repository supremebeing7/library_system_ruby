require './lib/book'
require './lib/author'
require './lib/patron'
require 'pg'
require 'date'

DB = PG.connect({:dbname => 'library_system'})

def ascii_art
  system "clear"
  puts "\e[1;31m
        dBBBBBBBBBBBBBBBBBBBBBBBBb
      BP YBBBBBBBBBBBBBBBBBBBBBBBb
     dB   YBb                 YBBBb
     dB    YBBBBBBBBBBBBBBBBBBBBBBBb
      Yb    YBBBBBBBBBBBBBBBBBBBBBBBb
       Yb    YBBBBBBBBBBBBBBBBBBBBBBBb
        Yb    YBBBBBBBBBBBBBBBBBBBBBBBb
         Yb    YBBBBBBBBBBBBBBBBBBBBBBBb
          Yb    YBBBBBBBBBBBBBBBBBBBBBBBb
           Yb   dBBBBBBBBBBBBBBBBBBBBBBBBb
            Yb dP=======================/
             YbB=======================(
              Ybb=======================(
               Y888888888888888888DSI8888b
"

end

def main_menu
  system("clear")
  ascii_art
  puts "\n\nWelcome to the library\n\n"
  puts "\e[32m * MAIN MENU *"
  puts "\e[0;30m'L' - Librarian Menu"
  puts "'P' - Patron Menu"
  choice = gets.chomp.upcase
  case choice
  when 'L'
    lib_menu
  when 'P'
    system "clear"
    puts "What is your name:"
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
  puts "\e[32m * PATRON MENU *"
  puts "\e[30m'C' - Checkout Books"
  puts "'S' - Show All Books"
  puts "'H' - Show checkout history"
  puts "'M' - Main menu"
  choice = gets.chomp.upcase
  case choice
  when 'C'
    checkout_menu(current_patron)
  when 'S'
    show_books_with_authors
  when 'H'
    show_checkout_history(current_patron)
  when 'M'
    main_menu
  else
    puts "Invalid entry"
    sleep(1.5)
    patron_menu(current_patron)
  end
end

def checkout_menu(current_patron)
  puts "'T' - Search by book Title"
  # puts "'A' - Search by Author"
  puts "'V' - View list of available books"
  choice = gets.chomp.upcase
  case choice
  when 'T'
    search_by_book_title(current_patron)
  # when 'A'
  #   search_by_author
  when 'V'
    select_from_available_books(current_patron)
  when 'M'
    main_menu
  else
    puts "Invalid entry"
    sleep(1.5)
    checkout_menu(current_patron)
  end
end

def search_by_book_title(current_patron)
  puts "What book would you like to find?"
  book_title = gets.chomp.capitalize
  begin
    new_book = Book.fetch_book(book_title)
    checkout(current_patron, book_index)
  rescue
    puts "No books found. Search again? (y/n)"
    case gets.chomp.upcase
    when 'Y' || 'YES'
      search_by_book_title(current_patron)
    else
      main_menu
    end
  end
end

def select_from_available_books(current_patron)
  show_available_books
  begin
    puts "Which book would you like to check out?"
    book_index = gets.chomp.to_i - 1
    checkout(current_patron, book_index)
  rescue
    puts "Invalid selection"
    checkout(current_patron, book_index)
  end
end

def checkout(current_patron, book_index)
  system("clear")
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
  puts "\e[32m * LIBRARIAN MENU *"
  puts "\e[30m'B' - Add Book"
  puts "'A' - Add Author"
  puts "'S' - Show All Books"
  puts "'O' - Show Overdue Books"
  puts "'M' - Main menu"
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
  when 'M'
    main_menu
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
  puts "How many copies? (numerical format)"
  qty = gets.chomp.to_i
  new_book = Book.create({'title' => book_title, 'category' => category, 'qty' => qty})
  puts "Who is the author?"
  author = gets.chomp.capitalize
  new_author = Author.create({'name' => author})
  new_author.add_to_join_table(new_book.id, new_author.id)
  puts "#{book_title} (#{category}), by #{author} added!"
  sleep(2)
  lib_menu
end

def add_author
  puts "Who is the author?"
  author = gets.chomp.capitalize
  new_author = Author.create({'name' => author})
  show_books
  puts "Which of these books did they write? Type '0' if none"
  book_id = gets.chomp.to_i
  if book_id == 0
  elsif book_id.is_a? Integer
    book_title = Book.fetch_book(book_id)['title']
    category_name = Book.fetch_category(book_title)
    new_author.add_to_join_table(book_id, new_author.id)
    puts "#{book_title} (#{category_name}), by #{author} added!"
  else
    puts "Invalid, please enter a number only"
    add_author
  end
  sleep(2)
  lib_menu
end

def show_available_books
  Patron.available_books.each_with_index do |book, index|
    puts "#{index + 1}. #{book.title} - Copies available: #{book.qty}"
  end
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
    category_name = Book.fetch_category(book.title)
    authors = Author.fetch_authors(book_id)
    puts "#{index + 1}. #{book.title} -- (category: #{category_name})\n"
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
