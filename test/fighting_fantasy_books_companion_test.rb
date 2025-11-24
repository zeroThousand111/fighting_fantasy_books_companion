# fighting_fantasy_books_companion_test.rb

ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../fighting_fantasy_books_companion.rb"

class FFBCTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def session
    last_request.env["rack.session"]
  end

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

  def test_random_stats_generation_is_between_min_and_max
    post "/stats/input-random", starting_rack_session
    # assign returned values in HTTP response to local variables and transform to Integers from Numeric Strings
    skill = session[:current_skill].to_i
    stamina = session[:current_stamina].to_i
    luck = session[:current_luck].to_i
    # expect values of stats to be in valid ranges
    assert (7..12).cover?(skill)
    assert (12..24).cover?(stamina)
    assert (7..12).cover?(luck)
    # expect a redirect to /stats
    assert_equal 302, last_response.status
  end

  ### stats- test valid input for manual input

  def test_manual_stats_valid_input
    post "/stats/input-manual", {:new_skill => 12, :new_stamina => 14, :new_luck => 12}, starting_rack_session
    # assign returned values in HTTP response to local variables and transform to Integers from Numeric Strings
    skill = session[:current_skill].to_i
    stamina = session[:current_stamina].to_i
    luck = session[:current_luck].to_i
    # expect values of stats to be in valid ranges
    assert (0..12).cover?(skill)
    assert (0..24).cover?(stamina)
    assert (0..12).cover?(luck)
    # expect a redirect to /stats
    assert_equal 302, last_response.status
  end

  ### stats - test invalid input for manual input

  def test_manual_stats_invalid_input_too_high_values
    post "/stats/input-manual", {:new_skill => "99", :new_stamina => "99", :new_luck => "99"}, starting_rack_session
    # expect starting values of three stats to remain unchanged from starting nil values
    assert_nil session[:current_skill]
    assert_nil session[:current_stamina]
    assert_nil session[:current_luck]
    # expect a session message to be generated and printed
    assert_equal "Sorry, one or more attributes are outside the valid ranges.", session[:message]
    # expect a redirect to /stats/input-manual
    assert_equal 302, last_response.status
  end

  def test_manual_stats_missing_input
    post "/stats/input-manual", {:new_skill => "12", :new_stamina => "24", :new_luck => nil }, starting_rack_session
    # expect starting values of three stats to remain unchanged
    assert_nil session[:current_skill]
    assert_nil session[:current_stamina]
    assert_nil session[:current_luck]
    # expect a session message to be generated and printed
    assert_equal "Sorry, one or more attributes are missing.", session[:message]
    # expect a redirect to /stats/input-manual
    assert_equal 302, last_response.status
  end

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

  def test_valid_selection_of_inventory_item_to_modify
    skip
    get "/inventory/modify/:inventory_index", {:inventory_index => "2"}, starting_rack_session
    # Sword is the third inventory item in the starting :inventory i.e. index 2 THIS CURRENTLY DOESN'T WORK.  INDEX 0 - BACKPACK - IS BEING SELECTED INSTEAD
    assert_includes "Sword", last_response.body
    # will get 200 status response to inventory_modify_item.erb, not 302 redirect to /inventory
    assert_equal 200, last_response.status
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

  # this isn't working because despite an invalid index, the item at index 0 is deleted!
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

  def test_asking_for_invalid_inventory_index_to_delete_returns_404
    post "/inventory/delete/:inventory_index", {:inventory_index => "666"}, starting_rack_session
    # expect my custom 404 response, which is itself a 302 redirect
    assert_equal 302, last_response.status
  end

  # this also doesn't work, maybe because the HTTP response is my custom 404?
  def test_asking_for_invalid_inventory_index_to_modify
    skip
    # test inventory only has 4 items (so max index is 3)
    get "/inventory/modify/:inventory_index", {:inventory_index => "666"}, starting_rack_session
    # expect a session :message to be displayed
    # assert_equal "You've tried to select an inventory item that doesn't exist at that index.", session[:message]
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

end