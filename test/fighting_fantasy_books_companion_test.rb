# fighting_fantasy_books_companion_test.rb

ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../fighting_fantasy_books_companion_test.rb"

DISALLOWED_HIGH_STARTING_ATTRIBUTE_SKILL = {
  skill: "13",
  stamina: "14",
  luck: "7"
}

DISALLOWED_LOW_STARTING_ATTRIBUTE_SKILL = {
  skill: "6",
  stamina: "14",
  luck: "7"
}

DISALLOWED_HIGH_STARTING_ATTRIBUTE_STAMINA = {
  skill: "7",
  stamina: "25",
  luck: "7"
}

DISALLOWED_LOW_STARTING_ATTRIBUTE_STAMINA = {
  skill: "7",
  stamina: "13",
  luck: "7"
}

DISALLOWED_HIGH_STARTING_ATTRIBUTE_LUCK = {
  skill: "7",
  stamina: "14",
  luck: "13"
}

DISALLOWED_LOW_STARTING_ATTRIBUTE_LUCK = {
  skill: "7",
  stamina: "14",
  luck: "6"
}

class FFBCTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def session
    last_request.env["rack.session"]
  end

  # tests go here

end