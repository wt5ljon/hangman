require 'yaml'

# Ruby implementation of the "Hangman" game
class Game
	@@FILENAME = "5desk.txt"

	def initialize
		@word = get_word
		@guess = "____________"[0..@word.length-1]
		@letters = "abcdefghijklmnopqrstuvwxyz".split("")
		@guesses_remaining = 7
		@correct_letters = []
		@incorrect_letters = []
	end

	def play
		continue_play = true
		while continue_play
			# don't decrement remaining guesses for correct guess
			if not display
				@guesses_remaining -= 1
			end
			# check if word has been guessed
			if @guess == @word || @guesses_remaining == 0
				continue_play = false
				message = "  You Win!!" if @guess == @word
				message = "  You Lose!!" if @guesses_remaining == 0
				puts `clear`
				puts ""
				puts display_man
				puts ""
				puts "  SECRET WORD: #{@guess}"
				puts ""
				puts "  Correct Letters: #{@correct_letters.join}"
				puts "  Incorrect Letters: #{@incorrect_letters.join}"
				puts ""
				puts message + " The secret word: #{@word}"
				puts ""
			end
		end
	end

	private

	# displays a stick-man hangman figure based on value of the
	# incorrect_letters attribute
	def display_man
		str = []
		temp = ""
		str.push("  +-------+   ")
		2.times { str.push("  |       |   ") }
		str.push @incorrect_letters.length >= 1 ? "  |       O   " : "  |"
		if @incorrect_letters.length == 2
			str.push "  |       |"
		elsif @incorrect_letters.length == 3
			str.push "  |       |--<"
		elsif @incorrect_letters.length >= 4
			str.push "  |    >--|--<"
		else
			str.push "  |"
		end
		str.push @incorrect_letters.length >= 5 ? "  |       |" : "  |"
		if @incorrect_letters.length == 6
			str.push "  |      /"
			str.push "  |     /"
		elsif @incorrect_letters.length == 7
			str.push "  |      / \\"
			str.push "  |     /   \\"
		else
			str.push "  |"
			str.push "  |"
		end
		str.push("  |           ")
		str.push("  +=============")
	  str
	end	

	# get a word from the file of words between 5 and 12 letters long
	def get_word
		words = []
		File.open(@@FILENAME).readlines.each do |line|
			line = line.downcase.chomp
			words.push(line) if line.length >= 5 && line.length <= 12
		end
		guess_word = words.sample
	end

	# display guess, number of guesses remaining
	def display
		found = false
		puts `clear`
		puts ""
		puts display_man
		puts ""
		puts "  SECRET WORD: #{@guess}"
		puts ""
		puts "  Correct Letters: #{@correct_letters.join}"
		puts "  Incorrect Letters: #{@incorrect_letters.join}"
		puts ""
		puts "  Enter a letter from the following letters or \"$\" to save game or \"&\" to quit"
		print "  #{@letters.join}: "
		while true
			letter = gets.downcase.chomp
			if letter == "&"
				puts ""
				puts "  Exiting game..."
				puts ""
				exit(true)
			end
			if letter == "$"
				puts ""
				print "  Enter a file name to save current game state: "
				name = gets.chomp
				File.open(name, "w") { |f| f.write(self.to_yaml) }
				return true
			end
			if @letters.index(letter)
				break
			else
				print "  Invalid letter entered. Retry: "
			end
		end

		if @word.index(letter)
			@correct_letters.push(letter)
			@word.split("").each_with_index do |char, i|
				found = true
				if char == letter
					@guess[i] = letter
				end
			end
		else
			@incorrect_letters.push(letter)
		end

		# remove the guessed letter from @letters attribute
		@letters[@letters.index(letter)] = ""
		found
	end

end

puts `clear`
puts ""
puts "  HANGMAN"
puts "  -------"
puts "  Enter \"1\" to play new game"
puts "  Enter \"2\" to load a saved game"
puts ""
print "  >> "
option = gets.chomp
while true
	if option == "1"
		hangman = Game.new
		hangman.play
		break
	elsif option == "2"
		puts ""
		print "  Enter filename of saved game: "
		filename = gets.chomp
		if File.exists?(filename)
			hangman = YAML.load(File.read(filename))
			hangman.play
			break
		else
			puts
			puts "  File not found.  Try again."
		end
	else
		puts
		puts "  Invalid Option Entered.  Try again."
		print "  >> "
		option = gets.chomp
	end
end

