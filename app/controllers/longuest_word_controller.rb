require 'open-uri'
require 'json'

class LonguestWordController < ApplicationController
  def game
    @letters = generate_grid(8)
    @start_time = Time.now
  end

  def score
    @letters = params[:grid].chars
    @start_time = Time.new(params[:start_time])
    @end_time = Time.now
    @attempt = params[:attempt]
    @result = run_game(@attempt, @letters, @start_time, @end_time)
  end
end


def generate_grid(grid_size)
  # TODO: generate random grid of letters
  letters = []
  grid_size.times { letters << ('A'..'Z').to_a.sample }
  return letters
end

def run_game(attempt, grid, start_time, end_time)
  # TODO: runs the game and return detailed hash of result
  result = {}
  time_to_answer = end_time - start_time
  result[:time] = time_to_answer
  translation = get_translation(attempt)
  result[:translation] = translation
  english_word = !translation.nil?
  result[:score] = get_score(attempt, time_to_answer, english_word, grid)
  result[:message] = message(attempt, grid, english_word)
  # dessous serie de test pour debugage
  # p "le temps de reponse est #{time_to_answer}"
  # p "la traduction est #{translation}"
  # p "est-ce un mot anglais ? : #{english_word}"
  # p "le resultat est : #{result[:get_score]}"
  # p "le message est #{result[:message]}"
  return result
end

def get_translation(word_in_english)
  # Prend un mot en anglais et retourne un string avec la definition en francais
  # recuperer le Jason Serialiser a partir du mot a traduire puis le tranformer
  # en hash  !!!! Pas de test sur le mot
  trad_hash = {}
  url = "http://api.wordreference.com/0.8/80143/json/enfr/#{word_in_english}"
  open(url) do |stream|
    trad_hash = JSON.parse(stream.read)
  end
  # On verifie si le mot existe
  if trad_hash.first != %w(Error NoTranslation)
    # A partir du hash retourner la premiere translation
    return trad_hash["term0"]["PrincipalTranslations"]["0"]["FirstTranslation"]["term"]
  else
    return nil
  end
end

def get_score(word, time_to_answer, english_word, grid)
  # retourne un int avec le score en fonction du temps de reponse et de la
  # longueur du mot
  if word.length * 11 - time_to_answer > 0 && english_word && in_the_grid?(word, grid)
    return word.length * 25  - time_to_answer / 5
  else
    return 0
  end
end

def in_the_grid?(word, grid)
  # repond un bool true si in grid false otherwise
  copy_grid = grid.dup
  in_the_grid = true
  tab_word = word.upcase.chars
  tab_word.each do |letter|
    copy_grid.include?(letter) ? copy_grid.delete_at(grid.index(letter)) : in_the_grid = false
  end
  return in_the_grid
end

def message(attempt, grid, english_word)
  # return appropriate message
  if !english_word
    return "not an english word"
  elsif in_the_grid?(attempt, grid)
    return "well done"
  else
    return "not in the grid"
  end
end