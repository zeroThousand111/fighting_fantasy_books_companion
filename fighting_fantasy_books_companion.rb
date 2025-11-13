# fighting_fantasy_books_companion.rb

=begin
FEATURES
+ track status of skill/stamina/luck scores
+ allow player to input scores manually
- allow random generation of starting scores


DEVELOPMENT IDEAS
+ validate that no attribute score is missing
+ validate starting attribute scores (they may go outside this range during play):
  + skill between 7 and 12
  + stamina between 14 and 24
  + luck between 7 and 12
- 
- attributes can go down, but rarely can go above the starting value
=end

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

## Fight Generators

def attack_strength
  two_d6 # + player skill or monster skill
end

## Input Collection and Validation

def missing_attribute?(array_of_attribute_strings)
  array_of_attribute_strings.any? { |attribute| attribute.nil? }
end

def validate_manual_starting_skill_and_luck(attribute)
  (7..12).cover?(attribute.to_i)
end

def validate_manual_starting_stamina(attribute)
  (14..24).cover?(attribute.to_i)
end

def validate_manual_starting_attributes(score) # return false unless all three attributes are within correct ranges
  validate_manual_starting_skill_and_luck(session[:starting_skill]) && validate_manual_starting_stamina(session[:starting_stamina]) && validate_manual_starting_skill_and_luck(session[:starting_luck])
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
  roll_two_random_dice_for_tray
  erb :stats
end

get "/input/manual" do
  erb :input
end

get "/help" do
  roll_two_random_dice_for_tray
  erb :help
end

post "/input/manual" do
  array_of_attribute_strings = [
    params[:starting_skill],
    params[:starting_stamina],
    params[:starting_luck]
  ]

  # array_of_attribute_integers = array_of_attribute_strings.map { |attribute| attribute.to_i }

  if missing_attribute?(array_of_attribute_strings)
    session[:message] = "Sorry, one or more attributes are missing."
    redirect "/input"
  elsif !validate_manual_starting_attributes(array_of_attribute_strings) # true if one or more attributes are outside the allowed starting ranges
    session[:message] = "Sorry, one or more attributes are outside the valid ranges."
    redirect "/input"
  else # all OK - store attributes in session hash and redirect to /index
    session[:starting_skill] = params[:starting_skill]
    session[:starting_stamina] = params[:starting_stamina]
    session[:starting_luck] = params[:starting_luck]

    session[:current_skill] = params[:starting_skill]
    session[:current_stamina] = params[:starting_stamina]
    session[:current_luck] = params[:starting_luck]
    redirect "/index"
  end
end

# get "/input/random" do
#   # erb :random
# end

post "/stats/input-random" do
  session[:starting_skill] = random_starting_skill_or_luck
  session[:starting_stamina] = random_starting_stamina
  session[:starting_luck] = random_starting_skill_or_luck
  # Is this syntax correct for assignment?
  session[:current_skill] = params[:starting_skill]
  session[:current_stamina] = params[:starting_stamina]
  session[:current_luck] = params[:starting_luck]

  # Does it need these instance variables to display them in front end?
  # How to retrieve above values from params?
  @current_skill = params[:current_skill]
  @current_stamina = 
  @current_luck = 
  
  redirect "/index"
end

get "/update" do
  "This is a placeholder response"
end


