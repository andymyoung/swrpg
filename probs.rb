# probs.rb
# FFG Star Wars narrative dice probability analysis
# March 7, 2017
# ayoung

require 'optparse'

options = Hash.new()

option_parser = OptionParser.new do |opts|
  opts.on("-d DICE") do |dice|
    options[:dice] = dice
  end
  opts.on("-h", "--help") do
    options[:help] = true
  end
end

option_parser.parse!

def show_help
  puts "loader reliability test script v0.01"
  puts "usage: loader [options] \n"
  puts "    -d DICE           Type and number of dice to roll:\n"
  puts '''                       a = ability
                       d = difficulty
                       p = proficiency
                       c = challenge
                       b = boost
                       s = setback'''
  puts "For example, 'ruby probs.rb -d aadd' would run 100000 rolls"
  puts "of two ability plus 2 difficulty dice"
end

def buildPool(dice)
  force = [-1, -1, -1, -1, -1, -1, -2, 1, 1, 2, 2, 2]
  ability = ["s", "s", "ss", "a", "a", "sa", "aa"] # s = succes, a = advantage
  difficulty = ["f", "ff", "b", "b", "b", "bb", "fb"] # f = failure, b = setBack
  proficiency = ["s", "s", "ss", "ss", "a", "sa", "sa","sa","aa", "aa", "t"] # t = triumph
  challenge = ["f", "f", "ff", "ff", "b", "fb", "fb","fb","bb", "bb", "d"] # d = despair
  boost = ["", "", "s", "sa", "aa", "a"]
  setback = ["", "", "f", "f", "b", "b"]
  dice_pool = ""
  dice_array = dice.split("")
  dice_array.each do |die|
    case die
    when "a"
      dice_pool += ability.sample
    when "d"
      dice_pool += difficulty.sample
    when "p"
      dice_pool += proficiency.sample
    when "c"
      dice_pool += challenge.sample
    when "b"
      dice_pool += boost.sample
    when "s"
      dice_pool += setback.sample
    end
  end
  return dice_pool
end

def parseRoll(roll)
  return {
    :success =>(roll.count("s") + roll.count("t") - roll.count("f") + roll.count("d")) > 0,
    :success_count => roll.count("s") + roll.count("t"),
    :advantage_count => roll.count("a"),
    :failure_count => roll.count("f") + roll.count("d"),
    :setback_count => roll.count("b"),
    :triumph_count => roll.count("t"),
    :despair_count => roll.count("d")
  }
end


if options[:help]
  show_help
elsif not options[:dice]
  puts "Command-line params required. Use -h option for help"
else
  sims = 100000
  passes = 0
  advantages = 0
  setbacks = 0
  triumphs = 0
  despairs = 0
  successes = 0

  sims.times do
    dice = buildPool(options[:dice])
    result = parseRoll(dice)
    if (result)[:success]
      passes += 1
    end
    advantages += result[:advantage_count]
    setbacks += result[:setback_count]
    triumphs += result[:triumph_count]
    despairs += result[:despair_count]
    successes += result[:success_count]
  end

  puts("#{sprintf '%.1f', passes/sims.to_f * 100}% success rate")
  puts("Successes: #{sprintf '%.1f', advantages/sims.to_f} per roll.")
  puts("Advantages: #{sprintf '%.1f', advantages/sims.to_f} per roll.")
  puts("Setbacks: #{sprintf '%.1f', setbacks/sims.to_f} per roll.")
  puts("Triumphs: #{sprintf '%.3f', triumphs/sims.to_f} per roll.")
  puts("Despairs: #{sprintf '%.3f', despairs/sims.to_f} per roll.")
end
