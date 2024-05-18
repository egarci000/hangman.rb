require 'json'

class Hangman
  def initialize(word=nil, word_display=nil, guesses_left=nil, incorrect_letters=nil, letters_entered=nil, wins_losses=nil, points=nil, load_game=nil)
    @guess = ""
    @secret_word =  word || get_secret_word
    @word_display = word_display || get_word_display
    @guesses_left = guesses_left || 7
    @incorrect_letters = incorrect_letters || []
    @letters_entered = letters_entered || []
    @wins_losses = wins_losses || [0, 0]
    @points = points || 0
    @load_game = load_game || false
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

    main_menu if @load_game == false
    get_guess if @load_game == true

  end

  def reset_variables
    @secret_word = get_secret_word
    @word_display = get_word_display
    @guesses_left = 7
    @incorrect_letters = []
    @letters_entered = []
    @game_over = false

    get_guess

  end

  def main_menu
    system("clear") || system("cls")
    puts "Press 1 to start a new game, 2 to load a previous game, 3 to view the scoring system, 4 to view high scores"
    puts "Press any other key to exit"
    answer = gets.chomp
    case answer
    when "1"
      get_guess
    when "2"
      load_game
    when "3"
      scoring_system
    when "4"
      high_scores
    else
      puts "Exiting"
    end
  end

  def save_game
    obj = {}
    instance_variables.map do |var|
      unsaved_inst_vars = [:@guess, :@hangman_stages, :@game_over]
      obj[var] = instance_variable_get(var) unless unsaved_inst_vars.include?(var)
    end

    print "Enter the file name you'd like your game to be saved under: "
    name = gets.chomp

    f = File.open("saved_games/#{name}.txt", "w")
    f.puts JSON.dump obj

    puts "Saved under #{name}.txt"
  end

  def load_game

    if Dir.children("saved_games").empty? == false
      system("clear") || system("cls")
      puts "Enter m to go back to main menu\n\n"

      Dir.children("saved_games").each do |file|
        puts "#{Dir.children("saved_games").index(file)+1} #{file}"
      end

      print "\nEnter the number corresponding to the file you'd like to open: "
      answer = gets.chomp

      File.open("saved_games/#{Dir.children("saved_games").at(answer.to_i-1)}").each do |line|
        $obj = JSON.parse(line)
      end

      begin
        $obj.keys.each do |key|
          instance_variable_set(key, $obj[key])
        end
      rescue NoMethodError => e
        system("clear") || system("cls")
        print "No saved game data found, enter b to go back to saved files: "
        answer = gets.chomp.downcase

        load_game if answer == "b"
      else
      end

    else
      system("clear") || system("cls")
      puts "No saved games found\n\n"
      print "Enter m to go back to the main menu: "
      answer = gets.chomp

      main_menu if answer == "m"
    end



    self.class.make_new_game($obj) if @game_over == false
  end

  def self.make_new_game(i_vars)
    puts "was called"
    arr_of_instance_values = i_vars.values
    p arr_of_instance_values
    puts @game_ove

    Hangman.new(arr_of_instance_values.at(0), arr_of_instance_values.at(1),
                arr_of_instance_values.at(2), arr_of_instance_values.at(3),
                arr_of_instance_values.at(4), arr_of_instance_values.at(5),
                arr_of_instance_values.at(6), true)
  end

  def scoring_system
    system("clear") || system("cls")
    puts "You receive points based on how many guesses are leftover when the secret word is guessed.\n\n"
    puts "If correctly entering the entire secret word as your guess you receive one point for every missing letter in the display of the secret word.\n\n"

    print "Enter m to go back to the main menu:   "
    answer = gets.chomp.downcase

    main_menu if answer == "m"
  end

  def high_scores
    system("clear") || system("cls")
    File.foreach("scores.txt") {|line| puts line}
    puts "\nPress m to go back to the main menu"
    answer = gets.chomp.downcase
    main_menu if answer == "m"
  end

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
    puts update_hangman
    puts "\n\n"
    puts @word_display
    puts "\nincorrect guesses: #{@incorrect_letters.join(",")}\n\n"
    if @game_over == false
      puts "Enter ! to save game"
      print "Please enter your guess:  "
      @guess = gets.chomp.downcase

      if @guess == "!"
        save_game
      elsif @guess == @secret_word
        check_game
      elsif @letters_entered.include?(@guess) == false && @guess.match(/[[:alpha:]]/) && @guess.length == 1
        @letters_entered.push(@guess)
        check_if_in_secret_word?(@guess)
      else
        get_guess
      end
    end
  end

  def check_if_in_secret_word?(guess)
    @secret_word.include?(guess) ? count_occurences(guess) : update_incorrect_letters(guess)
  end

  def count_occurences(guess)
    index = (0 ... @secret_word.length).find_all { |i| @secret_word[i, 1] == guess }
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
    print "#{@hangman_stages[@guesses_left]}                guesses left:  #{@guesses_left}"
  end

  def check_game
    if @guess == @secret_word
      @wins_losses[0] += 1
      hash_of_tally = @word_display.split("").tally {|t| t == "-"}
      count = hash_of_tally["-"] + @guesses_left
      @points += count
      @game_over = true

      get_guess
      puts "\nCongrats you won!"
      display_end_message
    elsif @word_display == @secret_word
      @wins_losses[0] += 1
      @points += @guesses_left
      @game_over = true

      get_guess
      puts "\nCongrats you won!"
      display_end_message
    elsif @guesses_left == 0
      @wins_losses[1] += 1
      @game_over = true

      get_guess
      puts "\nYou lost :("
      display_end_message
    else
      get_guess
    end
  end

  def display_end_message
    puts "\n\nSecret word was #{@secret_word}"
    puts "Guesses left: #{@guesses_left}"
    puts "Wins: #{@wins_losses[0]}, losses: #{@wins_losses[1]}. Points: #{@points}"
    print "\nWould you like to play again? y for yes, n for no:  "
    answer = gets.chomp.downcase

    if answer == "y"
      reset_variables
    else
      save_score
    end
  end

  def save_score
    print "\nWould you like to save your score, along with your win/loss record? y for yes, n for no:  "
    answer = gets.chomp.downcase

    if answer == "y"
      f = File.open("scores.txt", "a")
      puts "Please enter your name: "
      name = gets.chomp
      f.puts "#{name} score: #{@points}, win/loss record: #{@wins_losses[0]}W, #{@wins_losses[1]}L"
      puts "Score saved #{name}!"
    end
  end

end

new_game = Hangman.new
