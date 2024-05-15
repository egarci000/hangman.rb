
#pseudocode/mock code:
#when game starts, open dictionary and randomly select a word between 5 and 12 characters long for the secret word:
#random_line if dictictionary.random_line > 5 and random_line < 12 / while loop: while the word is not between the parameters, keep searching until found
#secret_word = get_random_line


#display count of incorrect guesses, 6 incorrect guesses until end of game
#each guess of a letter in which it is not in the secret word, add to global count or class count
#draw stickman figure using array: ["  O", "/", "|", "\", "  /", "    \"]
#each time count goes up, the appropriate symbols are shown together.
#Ex (count is 4) show arr_of_figure[range of 0..count]
# add 1 to indices to not show the head when count of incorrect guesses is 0


#display correct letters below stick figure, above asking for another letter, another field will display incorrect letters
#incorrect_letters = [], pushed to i_letters when that letter is not added to field showing correct letters
#field of letters is equal to dashes at the beginning of the game, corresponding to the length of the letter:
#some sort of method to populate this array with dashes corresponding to the length of the secret_word variable:
#while i < secret_word.length >>>> field_of_letters.push("-")


#replace dashes with correct letters by going through the secret_word array and selecting indices of that letter:
#iterate over secret_word array > select indices where that letter appears if applicable > populate field_of_letters using those indices collected, with the letter guessed
#populate_array(letter)
#def populate_array(letter)
# var = is_in_secret_word?(letter)
# if var
#   field_of_letters[index] = letter
# else
#   count += 1
#   incorrect_guesses.push(letter)
# end
# #
#

#to do:
#fix newline position of @hangman array, need limbs at appropriate heights
#make it so game ends with a loss if count equals 6, update hangman to be at full body. Include message, "you killed hangman :(, word was: @secret_word"
#send message and ask again for a different letter if letter chosen by user has already been guessed
#make everything neat
#serialize :(

#allow player to save game by pressing "!" at the start of any turn
#search for way to serialize game class
#when program loads, add option to allow you to open one of your saved games, which should arrive you at the correct positions you were at when you saved

dictionary = File.open("10k.txt")

class Hangman
  def initialize
    @count = 0
    @secret_word = get_secret_word
    @word_display = get_word_display
    @letters_guessed = []
    @incorrect_letters = []
    @guess = ""
    @hangman = [" O", "/", "|", "'\'", "  /", "'\'"]
    get_guess
  end

  attr_accessor :word_display, :secret_word

  def get_guess
    puts "secret: #{secret_word}, count: #{@count}"
    puts update_hangman if @count > 0
    puts @word_display

    puts "Please enter your guess: "
    @guess = gets.chomp.downcase
    check_if_in_secret_word?(@guess)
  end

  def get_word_display
    word_arr = []
    @secret_word.length.times {word_arr.push("-")}
    word_string = word_arr.join
  end

  def count_occurences(guess)
    index = (0 ... @secret_word.length).find_all { |i| @secret_word[i,1] == guess }
    update_word_display(index)
  end

  def update_word_display(index)

    update_display = @word_display.split("")
    index.each do |index|
      update_display[index] = @guess
    end
    @word_display = update_display.join
    check_game
  end

  def check_game
    if @word_display == @secret_word
      puts @secret_word
      puts "congrats you won!"
    else
      get_guess
    end
  end

  def get_secret_word
    secret_word = File.readlines("10k.txt").sample.chomp
    (secret_word.length >= 5 && secret_word.length <= 12) ? secret_word : get_secret_word
  end

  def increase_count
    @count += 1
    check_game
  end

  def update_hangman
    @hangman[0...@count]
  end

  def update_incorrect_letters(guess)
    @incorrect_letters.push(guess)
    increase_count
  end

  def check_if_in_secret_word?(guess)
    @letters_guessed.push(guess)
    @secret_word.include?(guess) ? count_occurences(guess) : update_incorrect_letters(guess)
  end
end

new_game = Hangman.new
