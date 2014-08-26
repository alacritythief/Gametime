require 'sinatra'
require 'csv'

TEAM_DATA = 'public/games.csv'

def csv_import(file=TEAM_DATA)
  @games = []

  CSV.foreach(file, headers: true, :header_converters => :symbol, :converters => :all) do |team|
    @games << team.to_hash
  end
end

def declare_variables
  @team_choice = params[:team]

  @teams = []
  @h_team_stats = []
  @a_team_stats = []
  @team_wins_loss = []

  @winners = []
  @losers = []

  @lose_hash = []
  @win_hash = []

  @win_calc = []
  @lose_calc = []
  @win_lose_calc = []

  @scoreboard = []
  @leaderboard = []
end

def calc_winners_losers
  @games.each do |stats|
    @teams << stats[:home_team]
    @teams << stats[:away_team]

    @h_team_stats << stats if stats[:home_team] == @team_choice
    @a_team_stats << stats if stats[:away_team] == @team_choice

    if stats[:home_score] > stats[:away_score]
      @winners << stats[:home_team]
      @losers << stats[:away_team]
    else
      @winners << stats[:away_team]
      @losers << stats[:home_team]
    end
  end
end

def uniq(array)
  array.uniq!
end

def num_win_loss
  @win_calc = @teams + @winners
  @lose_calc = @teams + @losers

  @lose_calc.each do |loser|
    @lose_hash << {loser => @lose_calc.grep(loser).size - 1}
  end

  @win_calc.each do |winner|
    @win_hash << {winner => @win_calc.grep(winner).size - 1}
  end
end

def calc_leaderboard
  @win_lose_calc = @win_hash.zip(@lose_hash)
  @win_lose_calc.each do |wins,loss|
    wins.each do |wteam,wscore|
      loss.each do |lteam,lscore|
        @scoreboard << {:name => wteam, :wins => wscore, :losses => lscore}
      end
    end
  end

  @scoreboard.each do |team|
    @team_wins_loss << team if team[:name] == @team_choice
  end

  @leaderboard = @scoreboard.sort_by { |team| [-team[:wins], team[:losses]] }
end

def calc_stats
  declare_variables
  calc_winners_losers
  uniq(@teams)
  num_win_loss
  uniq(@lose_hash)
  uniq(@win_hash)
  calc_leaderboard
end

# ROUTES

get '/' do
  redirect '/leaderboard'
end

get '/leaderboard' do
  csv_import
  calc_stats
  erb :leaderboard
end

get '/teams/:team' do
  csv_import
  calc_stats
  erb :team
end

get '/matches' do
  csv_import
  calc_stats
  erb :matches
end
