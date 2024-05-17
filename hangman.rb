#make everything neat
#serialize :(

#allow player to save game by pressing "!" at the start of any turn
#search for way to serialize game class
#when program loads, add option to allow you to open one of your saved games, which should arrive you at the correct positions you were at when you saved

#to do:
#serialize class using json - save file to a "saved-games" directory under Hangman directory.
#              Allow user to give the file a name or choose a default one
#start of every turn, direct user they can save game by pressing, "!", this will exit them out of the game, (cont.)
#             save the Hangman class and its instance variables, then save them to a JSON file.
#at the start of every game, allow the user to load in a saved game and display things correctly
#add hangman functionality

class Hangman
  def initialize
    @guess = ""
    @secret_word = get_secret_word
    @word_display = get_word_display
    @guesses_left = 7
    @incorrect_letters = []
    @letters_entered = []
    @wins_losses = [0, 0]
    @points = 0
    @game_over = false
    @hangman_stages = [
  "    |-----
    |    |
    |    O
    |   /|\\
    |   / \\
    |_________",
  "    |-----
    |    |
    |    O
    |   /|\\
    |   /
    |_________",
  "    |-----
    |    |
    |    O
    |   /|\\
    |
    |_________",
  "    |-----
    |    |
    |    O
    |   /|
    |
    |_________",
  "    |-----
    |    |
    |    O
    |   /
    |
    |_________",
  "    |-----
    |    |
    |    O
    |
    |
    |_________",
  "    |-----
    |    |
    |
    |
    |
    |_________",
  "    |-----
    |
    |
    |
    |
    |_________"
  ]

    get_guess
  end

  def reset_variables
    @secret_word = get_secret_word
    @word_display = get_word_display
    @guesses_left = 7
    @incorrect_letters = []
    @letters_entered = []

    get_guess
  end

  attr_accessor :secret_word

  def get_secret_word
    secret_word = File.readlines("10k.txt").sample.chomp
    (secret_word.length >= 5 && secret_word.length <= 12) ? secret_word : get_secret_word
  end

  def get_word_display
    word_arr = []
    @secret_word.length.times {word_arr.push("-")}
    word_arr.join
  end

  def get_guess
    system("clear") || system("cls")
    puts "Press ! to save game, ? to load a game file" if @guesses_left != 0
    puts update_hangman
    puts "\n"
    puts @word_display
    puts "\nincorrect guesses: #{@incorrect_letters.join(",")}"
    if @guesses_left != 0
      puts "Please enter your guess, guesses left: #{@guesses_left} "
      @guess = gets.chomp.downcase

      if @letters_entered.include?(@guess)
        get_guess
      else
        @letters_entered.push(@guess)
        check_if_in_secret_word?(@guess)
      end
    end
  end

  def check_if_in_secret_word?(guess)
    check_game if @guess == @secret_word && @game_over
    @secret_word.include?(guess) ? count_occurences(guess) : update_incorrect_letters(guess)
  end

  def count_occurences(guess)
    index = (0 ... @secret_word.length).find_all { |i| @secret_word[i,1] == guess }
    update_word_display(index)
  end

  def update_incorrect_letters(guess)
    @incorrect_letters.push(guess)
    decrease_guesses
  end

  def update_word_display(index)
    update_display = @word_display.split("")
    index.each do |index|
      update_display[index] = @guess
    end
    @word_display = update_display.join
    check_game
  end

  def decrease_guesses
    @guesses_left -= 1
    check_game
  end

  def update_hangman
    @hangman_stages[@guesses_left]
  end

  def check_game
    if @guess == @secret_word
      @wins_losses[0] += 1
      @points += 10 if @guess == @secret_word

      puts "\ncongrats you won!"
      display_end_message
    elsif @word_display == @secret_word
      @wins_losses[0] += 1
      @points += 1

      puts "\ncongrats you won!"
      display_end_message
    elsif @guesses_left == 0
      @wins_losses[1] += 1

      get_guess
      puts "\nYou lost :("
      display_end_message
    else
      get_guess
    end
  end

  def display_end_message
    puts "\n \nSecret word was #{@secret_word}"
    puts "guesses left: #{@guesses_left}"
    puts "Wins: #{@wins_losses[0]}, losses: #{@wins_losses[1]}. Points: #{@points}"
    puts "Would you like to play again? y for yes, n for no"
    answer = gets.chomp.downcase

    if answer == "y"
      reset_variables
    else
      @game_over = true
      save_score
    end
  end

  def save_score
    puts "Would you like to save your score, along with your win/loss record? y for yes, n for no"
    answer = gets.chomp
    f = File.open("scores.txt", "a")
    if answer == "y"
      puts "Please enter your name: "
      name = gets.chomp
      f.puts "#{name} score: #{@points}, win/loss record: #{@wins_losses[0]}W, #{@wins_losses[1]}L"
      puts "Score saved!"
    end
  end
end

new_game = Hangman.new
