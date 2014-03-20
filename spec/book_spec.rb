require 'spec_helper'

describe Book do
  it 'initializes with a title and a category' do
    test_book = Book.new({'title' => 'Huck Finn', 'category' => 'fiction'})
    test_book.should be_an_instance_of Book
  end

  it 'gives us the book title and category' do
    test_book = Book.new({'title' => 'Huck Finn', 'category' => 'fiction'})
    test_book.title.should eq 'Huck Finn'
    test_book.category.should eq 'fiction'
  end

  it 'creates the book as an instance' do
    test_book = Book.create({'title' => 'Huck Finn', 'category' => 'fiction', 'qty' => 13})
    test_book.should be_an_instance_of Book
  end

  # it 'creates and saves the given book to the DB' do
  #   test_book = Book.create({'title' => 'Huck Finn', 'category' => 'fiction'})
  #   Book.all.should eq [test_book]
  # end

end
