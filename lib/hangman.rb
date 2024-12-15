require 'yaml'

class Hangman
  def initialize(word_list_path, max_attempts = 6)
    @word_list_path = word_list_path
    @max_attempts = max_attempts
    @secret_word = ""
    @guessed_letters = []
    @wrong_guesses = []
    @hangman_parts = ["", " ", " ", " ", " ", " "]
  end

  def load_word_list
    if File.exist?(@word_list_path)
      File.readlines(@word_list_path).map(&:chomp).select { |word| word.length.between?(5, 12) }
    else
      puts "Word list file not found. Please provide a valid file."
      exit
    end
  end

  def choose_secret_word
    words = load_word_list
    words.sample
  end

  def display_hangman
    puts "------"
    puts @hangman_parts[0]
    puts @hangman_parts[1]
    puts @hangman_parts[2]
    puts @hangman_parts[3]
    puts @hangman_parts[4]
    puts @hangman_parts[5]
    puts "------"
  end

  def display_status
    display_word = @secret_word.chars.map { |char| @guessed_letters.include?(char) ? char : '_' }.join(' ')
    puts "\nWord: #{display_word}"
    puts "Guessed letters: #{@guessed_letters.join(', ')}"
    puts "Wrong guesses: #{@wrong_guesses.join(', ')}"
    puts "Remaining attempts: #{@max_attempts - @wrong_guesses.size}"
    display_hangman
  end

  def guess_the_letter
    print "\nEnter a letter: "
    letter = gets.chomp.downcase

    if letter.length != 1 || !letter.match?(/[a-z]/)
      puts "Invalid input. Please enter a single letter."
      return false
    end

    if @guessed_letters.include?(letter) || @wrong_guesses.include?(letter)
      puts "You already guessed '#{letter}'. Try a different letter."
      return false
    end

    if @secret_word.include?(letter)
      @guessed_letters << letter
      puts "Good job! '#{letter}' is correct!"
    else
      @wrong_guesses << letter
      @hangman_parts[@wrong_guesses.size - 1] = case @wrong_guesses.size
                                                when 1 then "  O  "
                                                when 2 then " /|  "
                                                when 3 then " /|\\ "
                                                when 4 then " /    "
                                                when 5 then " / \\ "
                                                end
      puts "Sorry! '#{letter}' is incorrect."
    end

    true
  end

  def is_winner?
    (@secret_word.chars - @guessed_letters).empty?
  end

  def is_loser?
    @wrong_guesses.size >= @max_attempts
  end

  def check_game_status
    if is_winner?
      puts "Congratulations, you won! The word was '#{@secret_word}'."
      true
    elsif is_loser?
      puts "No attempts left. You lost! The secret word was '#{@secret_word}'."
      display_hangman
      true
    else
      false
    end
  end

  def save_game
    File.open('game_save.yaml', 'w') do |file|
      YAML.dump({ secret_word: @secret_word, guessed_letters: @guessed_letters,
                  wrong_guesses: @wrong_guesses, max_attempts: @max_attempts }, file)
    end
    puts "Game saved successfully."
  end

  def load_game
    if File.exist?('game_save.yaml')
      saved_data = YAML.load(File.read('game_save.yaml'))
      @secret_word = saved_data[:secret_word]
      @guessed_letters = saved_data[:guessed_letters]
      @wrong_guesses = saved_data[:wrong_guesses]
      @max_attempts = saved_data[:max_attempts]
      puts "Game loaded successfully."
    else
      puts "No saved game found. Starting a new game."
    end
  end

  def start_game
    puts "Welcome to Hangman!"
    puts "Rules: Guess the secret word one letter at a time. You have #{@max_attempts} attempts."

    print "Do you want to load a saved game? (yes/no): "
    response = gets.chomp.downcase
    if response == 'yes'
      load_game
    else
      @secret_word = choose_secret_word
    end

    until check_game_status
      display_status
      guess_the_letter
    end

    print "Do you want to save the game? (yes/no): "
    save_game if gets.chomp.downcase == 'yes'
  end
end

# Start the game
word_list_path = "word_list.txt"
game = Hangman.new(word_list_path)
game.start_game
