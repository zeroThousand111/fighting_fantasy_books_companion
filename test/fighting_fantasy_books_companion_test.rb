# fighting_fantasy_books_companion_test.rb

ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../fighting_fantasy_books_companion.rb"

# constants for stats - check the format!!  A hash??!

# DISALLOWED_HIGH_STARTING_ATTRIBUTE_SKILL = {
#   skill: "13",
#   stamina: "14",
#   luck: "7"
# }

# DISALLOWED_HIGH_STARTING_ATTRIBUTE_STAMINA = {
#   skill: "7",
#   stamina: "25",
#   luck: "7"
# }

# DISALLOWED_HIGH_STARTING_ATTRIBUTE_LUCK = {
#   skill: "7",
#   stamina: "14",
#   luck: "13"
# }

class FFBCTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def session
    last_request.env["rack.session"]
  end

  # tests go here

  # def setup

  # end

  def starting_rack_session
    { "rack.session" => { gold: "0", 
                          bookmark: "1",  
                          inventory: ["Backpack", "Leather Armour", "Sword", "Packed Lunch"],
                          notes: ["My first note", "My second note", "My third note"]
                         }
                        }
  end

  ## helper method tests
  ## test helper methods explicitly (unit testing) or implicitly from running routes (integration testing)?  Decide if I want to do purely integration testing or include some unit testing too.  Might be fun to do a bit of both!?  But... I don't yet know how to implement unit tests without using a route (which will be integration testing!)

  ### test random stats give expected range of results

  ### test_is_not_an_empty_string?
  ### test_is_a_numeric_string?
  ### etc

  # def something
  # end

  ## routes - index/home
  
  def test_home_page
    get "/", starting_rack_session
    # we expect a redirect from / to /index
    assert_equal 302, last_response.status
  end

  def test_index_page
    get "/index", starting_rack_session
    assert_equal 200, last_response.status
    assert_includes last_response.body, "Here is your <em>adventure sheet</em>!"
  end

  ## routes - stats

  ### stats - test starting default values for stats are nil

  def test_default_stats_have_nil_value
    get "/stats", starting_rack_session
    assert_nil session[:new_skill]
    assert_nil session[:new_stamina]
    assert_nil session[:new_luck]

    get "/index", starting_rack_session
    assert_nil session[:new_skill]
    assert_nil session[:new_stamina]
    assert_nil session[:new_luck]
  end

  ### stats - test random stats give expected range of values for all three attributes

  ### stats- test valid input for manual input
  ### stats - test invalid input for manual input
  ### stats - test bad inputs for manual input

  ## routes - gold

  ### gold - test starting default value

  def test_default_gold_value_is_0
    get "/gold", starting_rack_session
    assert_equal "0", session[:gold]
  end

  ### gold - test valid value change

  def test_valid_gold_value_change_from_0_to_999
    post "/gold", {:updated_gold => "999"}, starting_rack_session
    # expect a change of value of bookmark to "999"
    assert_equal "999", session[:gold]
    # expect a redirect to /gold and gold.erb page
    assert_includes "gold", last_response.body
    assert_equal 302, last_response.status
  end

  ### gold - test invalid value change

  def test_invalid_gold_value_change_from_0_to_minus_1
    post "/gold", {:updated_gold => "-1"}, starting_rack_session
    # original value of gold should not change and should remain as 0
    assert_equal "0", session[:gold]
    # a session message should be created for printing on redirect
    assert_equal "Sorry, the number of gold pieces should be a number that is zero or more.", session[:message]
    # expect a redirect to /gold
    assert_equal 302, last_response.status
  end

  ### gold - test bad inputs

  def test_bad_input_gold_value_change_from_0_to_alphabetic_string
    post "/gold", {:updated_gold => "aaa"}, starting_rack_session
    # original value of gold should not change and should remain as 0
    assert_equal "0", session[:gold]
    # a session message should be created for printing on redirect
    assert_equal "Sorry, the number of gold pieces should be a number that is zero or more.", session[:message]
    # expect a redirect to /gold
    assert_equal 302, last_response.status
  end

  def test_bad_input_gold_value_change_from_0_to_empty_string
    post "/gold", {:updated_gold => ""}, starting_rack_session
    # original value of gold should not change and should remain as 0
    assert_equal "0", session[:gold]
    # a session message should be created for printing on redirect
    assert_equal "Sorry, the number of gold pieces should be a number that is zero or more.", session[:message]
    # expect a redirect to /gold
    assert_equal 302, last_response.status
  end

  ## routes - bookmark

  ### bookmark - test starting default value

  def test_default_bookmark_value_is_1
    get "/index", starting_rack_session
    assert_equal "1", session[:bookmark]
  end

  ### bookmark - test valid value change

  def test_valid_bookmark_value_change_from_1_to_400
    post "/bookmark", {:updated_bookmark => "400"}, starting_rack_session
    # expect a change of value of bookmark to "400"
    assert_equal "400", session[:bookmark]
    # expect a redirect to /bookmark and bookmark.erb page
    assert_includes "bookmark", last_response.body
    assert_equal 302, last_response.status
  end

  ### bookmark - test invalid value change

  def test_invalid_bookmark_value_change_from_1_to_801
    post "/bookmark", {:updated_bookmark => "801"}, starting_rack_session
    # original value of bookmark should not change and should remain as 1
    assert_equal "1", session[:bookmark]
    # a session message should be created for printing on redirect
    assert_equal "Sorry, the section number should be a number above zero and less than 801.", session[:message]
    # expect a redirect to /bookmark
    assert_equal 302, last_response.status
  end

  ### bookmark - test bad inputs

  def test_bad_input_bookmark_value_change_from_1_to_alphabetic_string
    post "/bookmark", {:updated_bookmark => "aaa"}, starting_rack_session
    # original value of bookmark should not change and should remain as 1
    assert_equal "1", session[:bookmark]
    # a session message should be created for printing on redirect
    assert_equal "Sorry, the section number should be a number above zero and less than 801.", session[:message]
    # expect a redirect to /bookmark
    assert_equal 302, last_response.status
  end

  def test_bad_input_bookmark_value_change_from_1_to_empty_string
    post "/bookmark", {:updated_bookmark => ""}, starting_rack_session
    # original value of bookmark should not change and should remain as 1
    assert_equal "1", session[:bookmark]
    # a session message should be created for printing on redirect
    assert_equal "Sorry, the section number should be a number above zero and less than 801.", session[:message]
    # expect a redirect to /bookmark
    assert_equal 302, last_response.status
  end

  ## routes - inventory

  ### inventory - test starting default value

  def test_default_inventory_contents
    get "/inventory", starting_rack_session
    assert_equal ["Backpack", "Leather Armour", "Sword", "Packed Lunch"], session[:inventory]

    get "/index",  starting_rack_session
    assert_equal ["Backpack", "Leather Armour", "Sword", "Packed Lunch"], session[:inventory]
  end

  ### inventory - test valid input

  def test_addition_of_valid_inventory_item
    post "/inventory", {:updated_inventory => "teSt IteM"}, starting_rack_session
    # Test item should be added to :inventory array in capitalized format
    assert_equal ["Backpack", "Leather Armour", "Sword", "Packed Lunch", "Test item"], session[:inventory]
    # expect a redirect to /inventory
    assert_equal 302, last_response.status
  end

  def test_valid_modification_of_inventory_item
    post "/inventory/modify/:inventory_index", {:updated_inventory => "teSt IteM", :inventory_index => "0"}, starting_rack_session
    # Backpack item should be modified to Test item in :inventory array in capitalized format at index 0
    assert_equal ["Test item", "Leather Armour", "Sword", "Packed Lunch"],  session[:inventory]
    # expect a redirect to /inventory
    assert_equal 302, last_response.status
  end

  def test_deletion_of_inventory_items
    post "/inventory/delete/:inventory_index", {:inventory_index => "0"},starting_rack_session
    # Backpack item at index 0 should be deleted
    assert_equal ["Leather Armour", "Sword", "Packed Lunch"],  session[:inventory]
    # expect a redirect to /inventory
    assert_equal 302, last_response.status
  end

  ### inventory - test invalid input

  def test_addition_of_invalid_inventory_item_empty_string
    post "/inventory", {:updated_inventory => ""}, starting_rack_session
    # Empty string item should NOT be added to :inventory array
    assert_equal ["Backpack", "Leather Armour", "Sword", "Packed Lunch"], session[:inventory]
    # expect a session :message to be displayed
    assert_equal "Sorry, the new item must contain at least one character.", session[:message]
    # expect a redirect to /inventory
    assert_equal 302, last_response.status
  end

  ### inventory - test bad inputs

  def test_asking_for_invalid_inventory_index_to_delete
    skip
    # test inventory only has 4 items (so max index is 3)
    post "/inventory/delete/:inventory_index", {:inventory_index => "666"}, starting_rack_session
    # :inventory array should remain unchanged
    assert_equal ["Backpack", "Leather Armour", "Sword", "Packed Lunch"], session[:inventory]
    # expect a session :message to be displayed
    assert_equal "You've tried to delete an inventory item that doesn't exist at that index.", session[:message]
    # expect a redirect to /inventory
    assert_equal 302, last_response.status
  end

  ### add bad html - how to test?
  #### other bad inputs


  ## routes - notes

  ### notes - test starting default value

  def test_default_notes_contents
    get "/notes", starting_rack_session
    assert_equal ["My first note", "My second note", "My third note"], session[:notes]

    get "/index",  starting_rack_session
    assert_equal ["My first note", "My second note", "My third note"], session[:notes]
  end

  ### notes - test valid input
  ### notes - test invalid input
  ### notes - test bad inputs

end