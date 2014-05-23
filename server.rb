require 'json'
require 'sinatra'
require 'redis'

def get_connection
  if ENV.has_key?("REDISCLOUD_URL")
    Redis.new(url: ENV["REDISCLOUD_URL"])
  else
    Redis.new
  end
end

def find_articles
  redis = get_connection
  serialized_articles = redis.lrange("slacker:articles", 0, -1)

  articles = []

  serialized_articles.each do |article|
    articles << JSON.parse(article, symbolize_names: true)
  end

  articles
end

def save_article(url, title, description, name)
  article = { url: url, title: title, description: description, name: name }

  redis = get_connection
  redis.rpush("slacker:articles", article.to_json)
end

def article_exists(params)
  errors = []
  articles = find_articles
  articles.each do |article|
    if article[:url] == params
      errors << 1
    end
  end
  errors
end


get '/' do
@articles = find_articles

erb :home
end

get '/new' do

  erb :new
end

post '/new' do
  @url = params[:url]
  @errors = article_exists(@url)
  @url_exists = "ARTICLE ALREADY EXISTS"

  if !@errors.empty?

    erb :new
  else
    save_article(params[:url],params[:new_article],params[:description], params[:name])

    redirect '/'
  end
end
