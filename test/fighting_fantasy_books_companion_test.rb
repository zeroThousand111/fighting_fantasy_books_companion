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

  ### inventory - valid test input

  def test_addition_of_valid_inventory_item
    post "/inventory", {:updated_inventory => "teSt IteM"}, starting_rack_session
    # Test item should be added to :inventory array in capitalized format
    assert_equal ["Backpack", "Leather Armour", "Sword", "Packed Lunch", "Test item"], session[:inventory]
    # expect a redirect to /inventory
    assert_equal 302, last_response.status
  end

  def test_valid_selection_of_inventory_item_to_modify
    get "/inventory/modify/2", starting_rack_session
    # Sword is the third inventory item in the starting :inventory i.e. index 2 and so the body of the HTTP response will have "Sword" as the value of `value` of the `<input>` element
    assert_includes last_response.body, "Sword"
    # will get 200 status response to inventory_modify_item.erb, not 302 redirect to /inventory
    assert_equal 200, last_response.status
  end

  def test_valid_modification_of_inventory_item
    post "/inventory/modify/0", {:updated_inventory => "teSt IteM" }, starting_rack_session
    # Backpack item should be modified to Test item in :inventory array in capitalized format at index 0
    assert_equal ["Test item", "Leather Armour", "Sword", "Packed Lunch"],  session[:inventory]
    # expect a redirect to /inventory
    assert_equal 302, last_response.status
  end

  def test_deletion_of_inventory_item
    post "/inventory/delete/0", starting_rack_session
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
    # test inventory only has 4 items (so max index is 3)
    post "/inventory/delete/999", starting_rack_session
    # :inventory array should remain unchanged
    assert_equal ["Backpack", "Leather Armour", "Sword", "Packed Lunch"], session[:inventory]
    # expect a session :message to be displayed
    assert_equal "You've tried to delete an inventory item that doesn't exist at that index.", session[:message]
    # expect a redirect to /inventory
    assert_equal 302, last_response.status
  end

  def test_asking_for_invalid_inventory_index_to_modify
    # test inventory only has 4 items (so max index is 3)
    get "/inventory/modify/999", starting_rack_session
    # expect a session :message to be displayed
    assert_equal "You've tried to select an inventory item that doesn't exist at that index.", session[:message]
    # expect a redirect to /inventory
    assert_equal 302, last_response.status
  end

  def test_modifying_an_inventory_item_to_an_empty_string
    # modifying item at index 1 i.e. Leather Armour to become an empty string ""
    post "/inventory/modify/1", {:updated_inventory => ""}, starting_rack_session
    # route should initialise a new session message which will be displayed
    assert_equal "Sorry, the modified item must contain at least one character.", session[:message]
    assert_equal 302, last_response.status
  end

  ### test bad html is handled - LSBot assisted test
  def test_modifying_item_with_malicious_html
    # 1. Define the malicious input and its expected escaped version
    malicious_input = "<script>alert('pwned')</script>"
    escaped_output = "&lt;script&gt;alert(&#39;pwned&#39;)&lt;/script&gt;"

    # 2. POST the malicious data to update an inventory item
    post "/inventory/modify/1", { updated_inventory: malicious_input }, starting_rack_session

    # The app should redirect after a POST
    assert_equal 302, last_response.status

    # # 3. Follow the redirect to the page where the data is displayed
    get last_response["Location"]

    # # 4. Assert that the final page's body contains the ESCAPED HTML
    assert_equal 200, last_response.status
    assert_includes last_response.body, escaped_output

    # # 5. (Optional but good practice) Assert that the raw, unescaped HTML is NOT present
    refute_includes last_response.body, malicious_input
  end

  #### other bad inputs?

  ## routes - notes

  ### notes - test starting default value

  def test_default_notes_contents
    get "/notes", starting_rack_session
    assert_equal ["My first note", "My second note", "My third note"], session[:notes]

    get "/index",  starting_rack_session
    assert_equal ["My first note", "My second note", "My third note"], session[:notes]
  end

  ### notes - test valid input

  def test_addition_of_valid_notes_item
    post "/notes", {:updated_notes => "teSt IteM"}, starting_rack_session
    # Test item should be added to :inventory array in capitalized format
    assert_equal ["My first note", "My second note", "My third note", "Test item"], session[:notes]
    # expect a redirect to /notes
    assert_equal 302, last_response.status
  end

  def test_valid_selection_of_note_item_to_modify
    get "/notes/modify/2", starting_rack_session
    # "My third note" is the third note item in the starting :notes i.e. index 2 and so the body of the HTTP response will have "My third note" as the value of `value` of the `<input>` element
    assert_includes last_response.body, "My third note"
    # will get 200 status response to notes_modify_item.erb, not 302 redirect to /notes
    assert_equal 200, last_response.status
  end

  def test_valid_modification_of_note_item
    post "/notes/modify/0", {:updated_note => "teSt IteM"}, starting_rack_session
    # "My first note" item should be modified to "Test item" in :notes array in capitalized format at index 0
    assert_equal ["Test item", "My second note", "My third note"],  session[:notes]
    # expect a redirect to /notes
    assert_equal 302, last_response.status
  end

  def test_deletion_of_note_item
    post "/notes/delete/0", starting_rack_session
    # Backpack item at index 0 should be deleted
    assert_equal ["My second note", "My third note"],  session[:notes]
    # expect a redirect to /notes
    assert_equal 302, last_response.status
  end

  ### notes - test invalid input

  def test_addition_of_invalid_notes_item_empty_string
    post "/notes", {:updated_notes => ""}, starting_rack_session
    # Empty string item should NOT be added to :notes array
    assert_equal ["My first note", "My second note", "My third note"], session[:notes]
    # expect a session :message to be displayed
    assert_equal "Sorry, the new note must contain at least one character.", session[:message]
    # expect a redirect to /inventory
    assert_equal 302, last_response.status
  end

  ### notes - test bad inputs

  def test_asking_for_invalid_note_index_to_delete
    # test notes array only has 3 items (so max index is 2)
    post "/notes/delete/999", starting_rack_session
    # :inventory array should remain unchanged
    assert_equal ["My first note", "My second note", "My third note"], session[:notes]
    # expect a session :message to be displayed
    assert_equal "You've tried to delete a note that doesn't exist at that index.", session[:message]
    # expect a redirect to /notes
    assert_equal 302, last_response.status
  end

  def test_asking_for_invalid_note_index_to_modify
    # test notes array only has 3 items (so max index is 2)
    get "/notes/modify/999", starting_rack_session
    # expect a session :message to be displayed
    assert_equal "You've tried to select a note that doesn't exist at that index.", session[:message]
    # expect a redirect to /notes
    assert_equal 302, last_response.status
  end

  def test_modifying_a_note_item_to_an_empty_string
    # modifying item at index 1 i.e. "My second note" to become an empty string ""
    post "/notes/modify/1", {:updated_note => ""}, starting_rack_session
    # route should initialise a new session message which will be displayed
    assert_equal "Sorry, the modified note must contain at least one character.", session[:message]
    assert_equal 302, last_response.status
  end

  ### test bad html is handled - LSBot assisted test
  def test_modifying_note_with_malicious_html
    # 1. Define the malicious input and its expected escaped version
    malicious_input = "<script>alert('pwned')</script>"
    escaped_output = "&lt;script&gt;alert(&#39;pwned&#39;)&lt;/script&gt;"

    # 2. POST the malicious data to update an inventory item
    post "/notes/modify/1", { updated_note: malicious_input }, starting_rack_session

    # The app should redirect after a POST
    assert_equal 302, last_response.status

    # # 3. Follow the redirect to the page where the data is displayed
    get last_response["Location"]

    # # 4. Assert that the final page's body contains the ESCAPED HTML
    assert_equal 200, last_response.status
    assert_includes last_response.body, escaped_output

    # # 5. (Optional but good practice) Assert that the raw, unescaped HTML is NOT present
    refute_includes last_response.body, malicious_input
  end

  #### other bad inputs?

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