require 'sinatra';
require 'sinatra/reloader';
require 'pg';
require 'time';
require 'omniauth-github';


configure do
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']

  use OmniAuth::Builder do
    provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
  end
end

configure :development do
  require 'pry'
end

def db_connection
  begin
    connection = PG.connect(dbname:'monolog')
    yield(connection)
  ensure
    connection.close
  end
end

def user_from_omniauth(auth)
  {
    uid: auth.uid,
    provider: auth.provider,
    username: auth.info.nickname,
    name: auth.info.name,
    email: auth.info.email,
    avatar_url: auth.info.image
  }
end

def find_or_create_user(attr)
  find_user_by_uid(attr[:uid]) || create_user(attr)
end

def find_user_by_uid(uid)
  sql = 'SELECT * FROM users WHERE uid = $1 LIMIT 1'

  user = db_connection do |db|
    db.exec_params(sql, [uid])
  end

  user.first
end

def find_user_by_id(id)
  sql = 'SELECT * FROM users WHERE id = $1 LIMIT 1'

  user = db_connection do |db|
    db.exec_params(sql, [id])
  end

  user.first
end

def create_user(attr)
  sql = %{
    INSERT INTO users (uid, provider, username, name, email, avatar_url)
    VALUES ($1, $2, $3, $4, $5, $6);
  }

  db_connection do |db|
    db.exec_params(sql, attr.values)
  end
end

def all_users
  db_connection do |db|
    db.exec('SELECT * FROM users')
  end
end

def authenticate!
  unless current_user
    flash[:notice] = 'You need to sign in before you can go there!'
    redirect '/'
  end
end

helpers do
  def signed_in?
    !current_user.nil?
  end

  def current_user
    find_user_by_id(session['user_id'])
  end
end

get '/' do
  redirect '/monolog'
end

get '/users' do
  authenticate!
  @users = all_users

  erb :'users/index'
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']
  user_attributes = user_from_omniauth(auth)
  user = find_or_create_user(user_attributes)

  session['user_id'] = user['id']
  flash[:notice] = 'You have successfully logged in.'

  redirect '/users'
end

get '/sign_out' do
  session['user_id'] = nil
  flash[:notice] = 'You have successfully logged out.'
  redirect '/'
end

get '/monolog' do
  sql = 'SELECT content, time FROM status ORDER BY time DESC'
  db_connection do |conn|
    @status = conn.exec(sql)
  end
  @time = Time.now
  erb :index
end

get '/monolog/positive' do
  search = 'SELECT content, time FROM status WHERE mood = 1 ORDER BY time DESC'
    db_connection do |conn|
      @status = conn.exec_params(search)
    end

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

  sql = 'SELECT time, mood, content FROM status WHERE time BETWEEN $1 AND $2'
  db_connection do |conn|
    @moods = conn.exec(sql,[t1,t2])
  end
  @moods = @moods.to_a

  @contents = []
  @moods.each do |mood|
    @contents << mood['content']
  end

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


set :views, File.dirname(__FILE__) + '/views'
set :public_folder, File.dirname(__FILE__) + '/public'

