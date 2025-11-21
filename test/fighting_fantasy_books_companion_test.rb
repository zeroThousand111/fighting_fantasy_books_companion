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
  ## test helper methods explicitly or implicitly from running routes?  Decide if I want to do purely integration testing or include some unit testing too.  Might be fun to do a bit of both!?

  ### test random stats give expected range of results
  ### test is_not_an_empty_string?
  ### test is_a_numeric_string?
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

  ### test random stats give expected range of values for all three attributes

  ### test valid input for manual input
  ### test invalid input for manual input
  ### test bad inputs for manual input

  ## routes - gold

  def test_default_gold_value_is_0
    get "/gold", starting_rack_session
    assert_equal "0", session[:gold]
  end

  def test_valid_gold_value_change_from_0_to_999
    post "/gold", {:updated_gold => "999"}, starting_rack_session
    # expect a change of value of bookmark to "999"
    assert_equal "999", session[:gold]
    # expect a redirect to /gold and gold.erb page
    assert_includes "gold", last_response.body
    assert_equal 302, last_response.status
  end

  def test_invalid_gold_value_change_from_0_to_minus_1
    post "/gold", {:updated_gold => "-1"}, starting_rack_session
    # original value of gold should not change and should remain as 0
    assert_equal "0", session[:gold]
    # a session message should be created for printing on redirect
    assert_equal "Sorry, the number of gold pieces should be a number that is zero or more.", session[:message]
    # expect a redirect to /gold
    assert_equal 302, last_response.status
  end

  ### test bad inputs

  ## routes - bookmark

  def test_default_bookmark_value_is_1
    get "/index", starting_rack_session
    assert_equal "1", session[:bookmark]
  end

  def test_valid_bookmark_value_change_from_1_to_400
    post "/bookmark", {:updated_bookmark => "400"}, starting_rack_session
    # expect a change of value of bookmark to "400"
    assert_equal "400", session[:bookmark]
    # expect a redirect to /bookmark and bookmark.erb page
    assert_includes "bookmark", last_response.body
    assert_equal 302, last_response.status
  end

  def test_invalid_bookmark_value_change_from_1_to_801
    post "/bookmark", {:updated_bookmark => "801"}, starting_rack_session
    # original value of bookmark should not change and should remain as 1
    assert_equal "1", session[:bookmark]
    # a session message should be created for printing on redirect
    assert_equal "Sorry, the section number should be a number above zero and less than 401.", session[:message]
    # expect a redirect to /bookmark
    assert_equal 302, last_response.status
  end

  ### test bad inputs

  ## routes - inventory

  def test_default_inventory_contents
    get "/inventory", starting_rack_session
    assert_equal ["Backpack", "Leather Armour", "Sword", "Packed Lunch"], session[:inventory]

    get "/index",  starting_rack_session
    assert_equal ["Backpack", "Leather Armour", "Sword", "Packed Lunch"], session[:inventory]
  end

  ### test valid input
  ### test invalid input
  ### test bad inputs

  ## routes - notes

  def test_default_notes_contents
    get "/notes", starting_rack_session
    assert_equal ["My first note", "My second note", "My third note"], session[:notes]

    get "/index",  starting_rack_session
    assert_equal ["My first note", "My second note", "My third note"], session[:notes]
  end

  ### test valid input
  ### test invalid input
  ### test bad inputs

end