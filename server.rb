require 'sinatra';
require 'sinatra/reloader';
require 'pg';
require 'gchart'
require 'pry';
require 'time';
require 'chartkick';

def db_connection
  begin
    connection = PG.connect(dbname:'monolog')
    yield(connection)
  ensure
    connection.close
  end
end

get '/monolog' do
  sql = 'SELECT content, time FROM status'
  db_connection do |conn|
    @status = conn.exec(sql)
  end
  @status=@status.to_a.reverse
  @time = Time.now
  erb :index
end

get '/monolog/mood_analyzer' do
  @year = params[:year].to_i
  @month = params[:month].to_i

  #if there's no month then get all the moods for the whole year
  #if !defined?(@month) || @month.nil?
  if @month == 0
    t1 = Time.new(@year)
    t2 = Date.new(@year).next_year.to_time
  #else get the moods for a specific month
  else
    t1 = Time.new(@year,@month)
    t2 = Date.new(@year,@month).next_month.to_time
  end

  sql = 'SELECT time, mood FROM status WHERE time BETWEEN $1 AND $2'
  db_connection do |conn|
    @moods = conn.exec(sql,[t1,t2])
  end
  @moods = @moods.to_a
  erb :mood_analyzer
end




post '/monolog' do
  status = params['status']
  if params['positive']
    mood = 1
  elsif params['negative']
    mood = -1
  end

  insert = 'INSERT INTO status(content,mood,time) VALUES($1, $2, now())'
  db_connection do |conn|
    conn.exec_params(insert,[status, mood])
  end

  redirect '/monolog'
end

# post '/monolog/:id' do
#   id = params[:id]
#   insert = 'DELETE FROM status WHERE id = $1'
#   db_connection do |conn|
#     conn.exec_params(insert,[id])
#   end
#   redirect '/monolog'
# end

# post '/monolog/:id/edit'do
#   edit = params['edit']
#   sql = 'UPDATE status SET status(content) VALUES($1)'
#   db_connection do |conn|
#     conn.exec_params(update,[status])
#   end
#   redirect '/monolog'
# end

set :views, File.dirname(__FILE__) + '/views'
set :public_folder, File.dirname(__FILE__) + '/public'

