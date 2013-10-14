#!/usr/bin/env ruby

class Bot

  def initialize
    @history = []
  end

  def received_init?
    @input = gets
    return true if  @input == "init\n"
    received_init?
  end

  def calculate_move
    if @history.count < 5
      %w{ rock paper scissors }.sample
    else
      defeat most_frequent_enemy_play
    end
  end

  def start_play_loop
    send_move
  end

  def send_move
    p "#{calculate_move}\n"
    collect_response
  end

  def collect_response
    @input = gets
    exit 0 if @input.nil?
    @history << @input.chomp.split(' ')
    send_move
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
    enemy_plays = []
    @history.each do |p| enemy_plays << p[1] end
    uniq_play_counts = Hash.new(0)
    enemy_plays.each do |i| uniq_play_counts[i] += 1 end
    uniq_play_counts = uniq_play_counts.sort_by {|k,v| v}.reverse
    most_freq_enemy_play = uniq_play_counts.first.first
  end

end


bot = Bot.new

bot.start_play_loop if bot.received_init?
