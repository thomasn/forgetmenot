require File.dirname(__FILE__) + '/../test_helper'

class AddressTest < Test::Unit::TestCase
  fixtures :addresses
  
  def test_truth
    a = Address.find(addresses(:full_address).id)
    assert_not_nil a
    assert_instance_of Address, a
    assert_valid a
    assert a.errors.empty?
    assert_equal addresses(:full_address), a
  end                          

  def test_display_name
    a = Address.find(addresses(:full_address).id)
    assert_equal "Victoria Street, 27, Worcester, Worcestershire, 11111, UK", a.display_name
    
    a = Address.find(addresses(:empty_address).id)
    assert_equal "address ##{a.id}", a.display_name
  end
end
