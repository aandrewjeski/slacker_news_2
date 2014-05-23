require 'sinatra'
require 'csv'
require 'shotgun'
require 'pry'
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

def save_article(url, title, description)
  article = { url: url, title: title, description: description }

  redis = get_connection
  redis.rpush("slacker:articles", article.to_json)
end


def load_list
  articles =[]
  article = nil
  CSV.foreach('articles.csv', headers: true) do |row|
    article = {
      name: row ["name"],
      title: row["title"],
      url: row["url"],
      description: row["description"]
    }
  articles << article
  end
  articles
end

def article_exists(params)
  errors = []
  articles = load_list
  articles.each do |article|
    if article[:url] == params
      errors << 1
    end
  end
  errors
end


get '/' do
@articles = load_list

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
    article = [params[:name],params[:new_article],params[:url], params[:description]]
    CSV.open('articles.csv', 'a') do |csv|
      csv << article
    end
    redirect '/'
  end
end
