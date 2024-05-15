#make everything neat
#serialize :(

#allow player to save game by pressing "!" at the start of any turn
#search for way to serialize game class
#when program loads, add option to allow you to open one of your saved games, which should arrive you at the correct positions you were at when you saved

dictionary = File.open("10k.txt")



class Hangman
  def initialize
    @guess = ""
    @secret_word = get_secret_word
    @word_display = get_word_display
    @guesses_left = 6
    @incorrect_letters = []
    @wins_losses = [0, 0]

    get_guess
  end

  def reset_variables
    @secret_word = get_secret_word
    @word_display = get_word_display
    @guesses_left = 6
    @incorrect_letters = []

    get_guess
  end

  def get_secret_word
    secret_word = File.readlines("10k.txt").sample.chomp
    (secret_word.length >= 5 && secret_word.length <= 12) ? secret_word : get_secret_word
  end

  def get_word_display
    word_arr = []
    @secret_word.length.times {word_arr.push("-")}
    word_string = word_arr.join
  end

  def get_guess
    puts "Please enter your guess, guesses left: #{@guesses_left} "
    puts @word_display
    puts "incorrect guesses: #{@incorrect_letters.join(",")}"
    @guess = gets.chomp.downcase
    check_if_in_secret_word?(@guess)
  end

  def check_if_in_secret_word?(guess)
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

  def check_game
    if @word_display == @secret_word
      @wins_losses[0] += 1

      puts @secret_word
      puts "congrats you won!"
      puts "Wins: #{@wins_losses[0]}, losses: #{@wins_losses[1]}"
      puts "Would you like to play again? y for yes, n for no"
      answer = gets.chomp.downcase

      reset_variables if answer == "y"
    elsif @guesses_left == 0
      @wins_losses[1] += 1
      puts "You lost :(, the secret word was #{@secret_word}"
      puts "Wins: #{@wins_losses[0]}, losses: #{@wins_losses[1]}"
      puts "Would you like to play again? y for yes, n for no"
      answer = gets.chomp.downcase

      reset_variables if answer == "y"
    else
      get_guess
    end
  end
end

new_game = Hangman.new
