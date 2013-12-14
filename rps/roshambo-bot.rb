#!/usr/bin/env ruby
STDOUT.sync = true

Signal.trap("PIPE", "EXIT")

class Bot

  def initialize
    @history = []
    @uniq_play_counts = Hash.new(0)
  end

  def received_init?
    @input = gets
    return true if  @input == "init\n"
    received_init?
  end

  def calculate_move
    if @history.count < 5
      %w{ rock paper scissors }.shuffle.first
    else
      defeat most_frequent_enemy_play
    end
  end

  def start_play_loop
    while true
      send_move
    end
  end

  def send_move
    puts calculate_move
    collect_response
  end

  def collect_response
    @input = gets
    exit 0 if @input.nil?
    @history << @input.chomp.split(' ')
  end

  private

  def defeat move
    case move
    when 'rock'
      'paper'
    when 'paper'
      'scissors'
    when 'scissors'
      'rock'
    end
  end

  def most_frequent_enemy_play
    @uniq_play_counts[ @history[-1][1] ] += 1
    sorted_counts = @uniq_play_counts.sort_by {|k,v| v}.reverse
    most_freq_enemy_play = sorted_counts.first.first
  end

end


bot = Bot.new

bot.start_play_loop if bot.received_init?
