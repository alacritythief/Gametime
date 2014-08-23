require 'sinatra'
require 'sinatra/reloader'
require 'csv'
require 'pry'

# I can navigate to a page /leaderboard to view the summary of the league.
# Each team is displayed on this page.
# For each team, I can see how many wins and losses they have.

TEAM_DATA = 'public/games.csv'

def csv_import(file=TEAM_DATA)
  @games = []

  CSV.foreach(file, headers: true, :header_converters => :symbol, :converters => :all) do |team|
    @games << team.to_hash
  end
end

def wins

  @win_hash = []
  @teams = []
  @win_calc = []
  @lose_calc = []
  @winners = []
  @losers = []
  @lose_hash = []
  @winlose_hash = []

  @games.each do |stats|
    @teams << stats[:home_team]
    @teams << stats[:away_team]

    if stats[:home_score] > stats[:away_score]
      @winners << stats[:home_team]
      @losers << stats[:away_team]
    else
      @winners << stats[:away_team]
      @losers << stats[:home_team]

    end
  end

  @teams.uniq!

  @win_calc = @teams + @winners
  @lose_calc = @teams + @losers

  @lose_calc.each do |loser|
    @lose_hash << {loser => @lose_calc.grep(loser).size - 1}
  end

  @win_calc.each do |winner|
    @win_hash << {winner => @win_calc.grep(winner).size - 1}
  end

  @lose_hash.uniq!
  @win_hash.uniq!
  @lose_presort = @lose_hash.reduce({}, :update)
  @win_presort = @win_hash.reduce({}, :update)

  @leaderboard = @win_presort.sort_by { |team, wins| wins }.reverse
  @winlose_hash << @win_presort
  @winlose_hash << @lose_presort
end




# ROUTES

get '/' do
  redirect '/leaderboard'
end

get '/leaderboard' do
  csv_import
  wins
  binding.pry
  erb :leaderboard
end
