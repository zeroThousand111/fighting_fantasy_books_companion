=begin
## FUNCTIONS
A fighting fantasy tool:
1. A character generator
2. A monster generator
3. A fighting model

## CHARACTER GENERATOR

## MONSTER GENERATOR

## FIGHT MODEL

## HEIRARCHY

AliveObject
  - Player
  - Monster
    - Goblin

Game
  - Fight

=end

class AliveObject
  attr_reader :skill, :max_stamina
  attr_accessor :current_stamina, :name

  # def initialize(name) end
  def capital_name
    name.upcase
  end

  def to_s
    "#{capital_name} has a skill of #{skill} and current stamina of #{current_stamina}"
  end
end

class Player < AliveObject
  attr_reader :luck

  def initialize
    choice = ""
    loop do
      puts "Please choose a name for your hero:"
      choice = gets.chomp
      break unless choice.empty?
      puts "Please make sure you fill in a name for your hero!"
    end
    self.name = choice
    puts "You've decided to call your hero #{capital_name}?!  OK then..."
    puts ""

    @skill = rand(7..12)
    @max_stamina = rand(13..24)
    @current_stamina = @max_stamina
    @luck = rand(7..12)

    puts self
  end

  def to_s
    super + " and a luck score of #{luck}"
  end
end

class Monster < AliveObject
  # attr_accessor :monster_type

  OPTIONS = ['goblin', 'dragon']

  def initialize
    monster_type = ''
    loop do
      puts "What kind of monster do you want to fight?"
      puts "Goblin, or dragon!"
      choice = gets.chomp.downcase
      monster_type = choice
      break if OPTIONS.include?(choice)
      puts "That's not a valid choice, try again."
    end

    case monster_type
    when 'goblin'
      # @monster_type = Goblin.new
      @name = 'goblin'
      @skill = rand(5..8)
      @max_stamina = rand(5..12)
      @current_stamina = @max_stamina
    when 'dragon'
      @name = 'dragon'
      @skill = rand(12..15)
      @max_stamina = rand(22..36)
      @current_stamina = @max_stamina
    end

    puts self
  end

  # to_s is inherited from AliveObject class
end

# class Goblin < Monster
#   def initialize
#     super
#     @skill = rand(5..8)
#     @max_stamina = rand(5..12)
#     @current_stamina = @max_stamina
#     @name = 'goblin'
#   end
# end

class Game
  def line_break
    puts ""
    puts " - - - - - -"
    puts ""
  end

  def display_current_stats(hero, monster)
    puts "#{hero.capital_name}'s current stamina is #{hero.current_stamina} and #{monster.capital_name}'s is #{monster.current_stamina}."
  end

  def display_score(hero, monster, hero_score, monster_score)
    line_break
    puts "#{hero.capital_name}'s score is #{hero_score}"
    puts "#{monster.capital_name}'s score is #{monster_score}"
  end

  def fight(hero, monster)
    puts "Let's FIGHT!"
    loop do
      hero_score = hero.skill + rand(1..12)
      monster_score = monster.skill + rand(1..12)
      display_score(hero, monster, hero_score, monster_score)

      if hero_score > monster_score
        puts "#{hero.capital_name} wins the round and #{monster.capital_name} loses 2 stamina!"
        monster.current_stamina -= 2
      elsif monster_score > hero_score
        puts "#{monster.capital_name} wins the round and #{hero.capital_name} loses 2 stamina!!"
        hero.current_stamina -= 2
      else
        puts "This round is a draw!"
      end
      display_current_stats(hero, monster)
      break if monster.current_stamina <= 0 || hero.current_stamina <= 0
      puts "press the ENTER key to continue"
      gets.chomp
    end
  end

  def display_winner(hero, monster)
    line_break
    if monster.current_stamina <= 0
      puts "Congratulations!  You've won the fight!"
      puts "The #{monster.capital_name} lies dead at your feet."
    elsif hero.current_stamina <= 0
      puts "Bad luck!"
      puts "Your hero bites the dust and"
      puts "The #{monster.capital_name} bites your hero!"
    end
    puts "THE END..."
  end

  def play
    hero = Player.new
    line_break
    monster = Monster.new
    # puts hero.name, monster.name
    # puts hero.skill, monster.skill
    # puts hero, monster
    fight(hero, monster)
    display_winner(hero, monster)
  end
end

Game.new.play
