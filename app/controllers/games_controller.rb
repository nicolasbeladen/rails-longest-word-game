require "open-uri"
require "json"

class GamesController < ApplicationController
  ALPHABET = ("A".."Z").to_a
  def new
    @letters = Array.new(10) { ALPHABET.sample }
  end

  def score
    @word = params[:word]
    @letters = params[:letters].split
    @result = compute_result(@word, @letters)
    session[:total_score] ||= 0
    session[:total_score] += @word.length if @result == :valid_attempt
  end

  private

  def compute_result(word, letters)
    remaining_letters = letters.dup
    buildable = word.upcase.chars.all? do |letter|
      index = remaining_letters.index(letter)
      index && remaining_letters.delete_at(index)
    end

    return :not_in_grid unless buildable
    return :not_english unless english_word?(word)
    :valid_attempt
  end

  def english_word?(word)
    url = "https://dictionary.lewagon.com/#{word}"
    response = URI.open(url).read
    data = JSON.parse(response)
    data["found"]
  end
end
