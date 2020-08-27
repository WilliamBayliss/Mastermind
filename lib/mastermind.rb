class Player
    def initialize(name)
      @name = name
      @turns = 12
    end
    
    def name
      @name
    end
  
    def play(secret_code)
      @turns.downto(1) do |turn_count|
        puts "-" * 82
        puts "Choose 4 colors from the #{Game.colors} list"
        puts turn_count > 1 ? "Enter your guess. #{turn_count} turns left." : "Enter your guess. It's your last chance to win!"
        guess = gets.chomp.split(/\W+/)
  
        if guess.size == 4
          Game.validate(guess, secret_code)
        else
          puts "--> Enter 4 colors! <--"
        end
        
        if guess == secret_code
          puts "You haf cracked zhe enigma!"
          exit(0)
        elsif turn_count == 1
          puts "Hahaha, and zhe secret code vas #{secret_code}, you haf lost!"
          exit(0)
        else
          puts "You are wrong, zhe furher vill be pleased."
        end
        
      end
    end   
  end
  
  
  class Computer < Player
    def initialize
      @name = 'Computer'
      @turns = 12
    end
  
    def play(secret_code)
      colors = Game.colors[0..-1]
      res = []
      mutation = nil
      guess = [colors.shuffle!.pop] * 4 
      
      @turns.downto(1) do |turn_count|
        puts turn_count > 1 ? "#{turn_count} turns left and computer's guess is #{guess}" :
                     "#{i} turn left and computer's guess is #{guess}"
        black, white = Game.validate(guess, secret_code)
        
        if guess == secret_code
          puts "Computer won!"
          exit(0)
        elsif turn_count == 1
          puts "You won! Computer didn't get it!"
          exit(0)
        elsif mutation
          guess = mutation.shuffle!.pop      
        elsif res.size == 4
          mutation = toss(res)
          guess = mutation.shuffle!.pop
        elsif black > 0
          res << [guess[0]] * black unless res.size == 4
          res.flatten!
          guess = (res.size == 4) ? res : [colors.shuffle!.pop] * 4
        else
          guess = [colors.shuffle!.pop] * 4
        end
  
      end
    end 
    
    def toss(res)
      mutation = res.permutation.to_a.uniq
    end    
  end
  
  class Game
    @@colors = [
      'red', 'blue', 'green',
      'yellow', 'purple', 'pink'
    ]
  
    def self.colors
      @@colors
    end
  
    def self.validate(guess, secret_code)
      black = 0
      white = 0
      counted = []
  
      guess.each_with_index do |item, index|
        secret_code.each_with_index do |item_s, index_s|
          if item == item_s && index == index_s
            black += 1
            counted << index_s     
          elsif item == item_s && index != index_s 
            next if guess[index_s] == secret_code[index_s] || guess[index] == secret_code[index] || guess.index(item_s) < index && (counted.include? index_s)
            white += 1
            counted << index_s
            break
          end
        end
      end
  
      puts "-" * 21 
      puts "black: #{black} | white: #{white} |"
      puts "-" * 21
      [black, white]
    end 
   
    def initialize(player)
      @player = player
      @computer = Computer.new
    end
    
    def start
      loop do
        puts %q(----------------------
    Choose your role:
             1. Creator
             2. Guesser
  ----------------------)            
        role = gets.chomp.scan(/\d/)
  
        if role[0].to_i == 1
          create
        elsif role[0].to_i == 2        
          guess
        else
          puts "--> Invalid option <--"
        end
  
      end
    rescue Interrupt
      puts "--> Have a wonderful time! <--"
    end
    
    def guess
      secret_code = []
  
      until secret_code.size == 4
        secret_code << @@colors.sample
      end
      @player.play(secret_code) 
    end
    
    def create
      puts "Make a secret code of four colors"
      puts "Choose from the #{@@colors} list!"
      secret_code = gets.chomp.split(/\W+/)
  
  
      if secret_code.size != 4
        puts "The code should be 4 colors!"
      elsif secret_code.all? { |i| @@colors.include? i }
        @computer.play(secret_code)
      else
        puts "--> Choose four colors from the list! <--"
      end
    end        
  end
  
  me = Player.new("Ovsjah")
  game = Game.new(me)
  game.start