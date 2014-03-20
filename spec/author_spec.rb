require 'spec_helper'

describe Author do

  it 'creates an author with a name' do
    new_author = Author.new({'name' => 'John Steinbeck'})
    new_author.should be_an_instance_of Author
  end

  it 'creates and saves the author' do
    new_author = Author.create({'name' => 'John Steinbeck'})
    new_author.should be_an_instance_of Author
  end

  it 'creates and saves the given author to the DB' do
    test_author = Author.create({'name' => 'John Steinbeck'})
    Author.all.length.should eq 1
  end
end
