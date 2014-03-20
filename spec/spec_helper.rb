require 'rspec'
require 'pg'
require 'author'
require 'book'
require 'patron'


DB = PG.connect({:dbname => 'library_system_test'})

RSpec.configure do |config|
  config.after(:each) do
    DB.exec("DELETE FROM patrons *;")
    DB.exec("DELETE FROM checkouts *;")
    DB.exec("DELETE FROM books_authors *;")
    DB.exec("DELETE FROM authors *;")
    DB.exec("DELETE FROM books *;")
    DB.exec("DELETE FROM category *;")
    DB.exec("DELETE FROM copies *;")
  end
end


