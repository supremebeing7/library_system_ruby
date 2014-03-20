require 'spec_helper'

describe Patron do

  it 'creates a patron with a name' do
    new_patron = Patron.new({'name' => 'Mark'})
    new_patron.should be_an_instance_of Patron
  end

  it 'creates and saves the patron' do
    new_patron = Patron.create({'name' => 'Mark'})
    new_patron.should be_an_instance_of Patron
  end

  it 'creates and saves the given patron to the DB' do
    test_patron = Patron.create({'name' => 'Mark'})
    Patron.all.length.should eq 1
  end

end
