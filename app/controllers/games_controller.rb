require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    session[:score] = 0 unless session[:score]
    @letters = []
    10.times do
      @letters << ('A'..'Z').to_a.sample
    end
    @stime = Time.now
  end

  def score
    session[:count] = 0 unless session[:count]
    session[:count] += 1
    if session[:count] > 5
      session[:count] = 0
      session[:score] = 0
    end
    @result = run_game(params[:word], params[:letters], Time.parse(params[:start]), Time.parse(params[:end]))
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }

    score_and_message = score_and_message(attempt, grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last

    result
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end
end
