# fighting_fantasy_books_companion.rb

# Require Dependencies

require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubi"

# Constants

DICE_ICONS = {
  1 => "dice-1-svgrepo-com.svg",
  2 => "dice-2-svgrepo-com.svg",
  3 => "dice-3-svgrepo-com.svg",
  4 => "dice-4-svgrepo-com.svg",
  5 => "dice-5-svgrepo-com.svg",
  6 => "dice-6-svgrepo-com.svg"
}.freeze

# Config

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end

# Before Actions

before do
  # creates an empty array value for :inventory unless it already exists
  session[:inventory] ||= ["Backpack", "Leather Armour", "Sword", "Packed Lunch"]
  session[:notes] ||= ["My first note", "My second note", "My third note"]
  # creates instance variable @inventory as alias for session[:inventory]
  @inventory = session[:inventory]
  @notes = session[:notes]
  # sets initial values for some session variables for a new session, but doesn't reassign if these keys already have a value assigned to them
  session[:bookmark] ||= "1"
  session[:gold] ||= "0"
end

# Helper Methods

## Random Number Generators

def one_d6
  rand(1..6)
end

def two_d6
  rand(2..12)
end

def roll_two_random_dice_for_tray
  @die1 = one_d6
  @die2 = one_d6
end

## Attribute Generators

def random_starting_skill_or_luck
  6 + one_d6
end

def random_starting_stamina
  12 + two_d6
end

## Input Collection and Validation

def is_not_an_empty_string?(string)
  string != nil && string.strip.length >= 1
end

def is_a_numeric_string?(string)
  string.chars.all? { |char| char.match?(/\d/) }
end

def valid_bookmark_value?(bookmark_value)
  bookmark_value.to_i > 0 && bookmark_value.to_i < 801 && is_a_numeric_string?(bookmark_value) && is_not_an_empty_string?(bookmark_value)
end

def valid_gold_value?(gold_value)
  gold_value.to_i >= 0 && is_a_numeric_string?(gold_value) && is_not_an_empty_string?(gold_value)
end

def missing_attribute?(array_of_attribute_strings)
  array_of_attribute_strings.any? { |attribute| attribute.nil? }
end

def valid_manual_skill_and_luck?(attribute)
  (7..12).cover?(attribute.to_i) && is_a_numeric_string?(attribute) && is_not_an_empty_string?(attribute)
end

def valid_manual_stamina?(attribute)
  (14..24).cover?(attribute.to_i) && is_a_numeric_string?(attribute) && is_not_an_empty_string?(attribute)
end

def valid_manual_attributes?(array_of_attribute_strings) # return false unless all three attributes are within correct ranges
  valid_manual_skill_and_luck?(array_of_attribute_strings[0]) && valid_manual_stamina?(array_of_attribute_strings[1]) && valid_manual_skill_and_luck?(array_of_attribute_strings[2])
end

def empty_string?(new_item)
  new_item.strip.size == 0
end

# Routes

get "/" do
  redirect "/index"
end

get "/index" do
  roll_two_random_dice_for_tray
  erb :index
end

get "/stats" do
  erb :stats
end

get "/stats/input-manual" do
  erb :stats_manual_input
end

post "/stats/input-manual" do
  array_of_attribute_strings = [
    params[:new_skill],
    params[:new_stamina],
    params[:new_luck]
  ]

  if missing_attribute?(array_of_attribute_strings) # true if one or more attributes are nil or an empty string
    session[:message] = "Sorry, one or more attributes are missing."
    redirect "/stats/input-manual"
  elsif !valid_manual_attributes?(array_of_attribute_strings) # true if one or more attributes are outside the allowed starting ranges
    session[:message] = "Sorry, one or more attributes are outside the valid ranges."
    redirect "/stats/input-manual"
  else # all OK - store attributes in session hash and redirect to /index
    session[:current_skill] = params[:new_skill]
    session[:current_stamina] = params[:new_stamina]
    session[:current_luck] = params[:new_luck]
    redirect "/stats"
  end
end

# Generates random stat values from button on "/stats"

post "/stats/input-random" do
  session[:current_skill] = random_starting_skill_or_luck
  session[:current_stamina] = random_starting_stamina
  session[:current_luck] = random_starting_skill_or_luck

  redirect "/stats"
end

get "/gold" do
  erb :gold
end

post "/gold" do
  gold_value = params[:updated_gold]

  if !valid_gold_value?(gold_value)
    session[:message] = "Sorry, the number of gold pieces should be a number that is zero or more."
    redirect "/gold"
  else
    session[:gold] = params[:updated_gold]
    redirect "/gold"
  end
end

get "/bookmark" do
  erb :bookmark
end

post "/bookmark" do
  bookmark_value = params[:updated_bookmark]
  
  if !valid_bookmark_value?(bookmark_value)
    session[:message] = "Sorry, the section number should be a number above zero and less than 401."
    redirect "/bookmark"
  else
    session[:bookmark] = params[:updated_bookmark]
    redirect "/bookmark"
  end
end

get "/inventory" do
  erb :inventory
end

post "/inventory" do
  new_item = params[:updated_inventory].capitalize
  if !is_not_an_empty_string?(new_item)
    session[:message] = "Sorry, the new item must contain at least one character."
  else
    @inventory << new_item
  end
  redirect "/inventory"
end

get "/inventory/modify/:inventory_index" do
  @inventory_index = params[:inventory_index].to_i
  @inventory_item = @inventory[@inventory_index]
  erb :inventory_modify_item
end

post "/inventory/modify/:inventory_index" do
  updated_item = params[:updated_inventory].capitalize
  inventory_index = params[:inventory_index].to_i
  if !is_not_an_empty_string?(updated_item)
    session[:message] = "Sorry, the modified item must contain at least one character."
  else
    @inventory[inventory_index] = updated_item
  end
  redirect "/inventory"
end

get "/inventory/delete/:inventory_index" do
  index = params[:inventory_index].to_i
  @inventory.delete_at(index)
  redirect "/inventory"
end

get "/notes" do
  erb :notes
end

post "/notes" do
  new_note = params[:updated_notes].capitalize
  if !is_not_an_empty_string?(new_note)
    session[:message] = "Sorry, the new note must contain at least one character."
  else
    @notes << new_note
  end
  redirect "/notes"
end

get "/notes/modify/:note_index" do
  @note_index = params[:note_index].to_i
  @note_item = @notes[@note_index]
  erb :notes_modify_item
end

post "/notes/modify/:note_index" do
  updated_note = params[:updated_note].capitalize
  note_index = params[:note_index].to_i
  if !is_not_an_empty_string?(updated_note)
    session[:message] = "Sorry, the modified note must contain at least one character."
  else
    @notes[note_index] = updated_note
  end
  redirect "/notes"
end

get "/notes/delete/:note_index" do
  index = params[:note_index].to_i
  @notes.delete_at(index)
  redirect "/notes"
end


get "/help" do
  roll_two_random_dice_for_tray
  erb :help
end
