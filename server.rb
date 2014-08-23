require 'sinatra'
require 'sinatra/reloader'
require 'csv'
require 'pry'

# I can navigate to a page /leaderboard to view the summary of the league.
# Each team is displayed on this page.
# For each team, I can see how many wins and losses they have.

TEAM_DATA = 'public/teams.csv'

def csv_import(file=TEAM_DATA)
  @teams = []

  CSV.foreach(file, headers: true, :header_converters => :symbol, :converters => :all) do |team|
    @teams << team.to_hash
  end
end

def wins

  @winners = []
  @losers = []
  @win_hash = []
  @lose_hash = []

  @teams.each do |stats|
    if stats[:home_score] > stats[:away_score]
      @winners << stats[:home_team]
      @losers << stats[:away_team]
      puts "#{stats[:home_team]} win"
    else
      @winners << stats[:away_team]
      @losers << stats[:home_team]
      puts "#{stats[:away_team]} win"
    end
  end

  @winners.each do |winner|
    @win_hash << {winner => @winners.grep(winner).size}
  end

  @win_hash = @win_hash.uniq #Generates an array with winners and their number of wins

  @losers.each do |loser|
    @lose_hash << {loser => 0}
  end

  @leaderboard = @win_hash + @lose_hash

  # @win_hash.each do |winner|
  #   puts "#{winner.keys.join} win #{winner.values.join}"
  # end



  # in testing
  # @test.map {|h| h.values }.uniq
  # @test.map {|h| h.keys }.uniq

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

#comapring teams

# if @teams[0][:home_score] > @teams[0][:away_score]
#    print 'pats win'
#  else
#    print 'broncos win'
#  end
