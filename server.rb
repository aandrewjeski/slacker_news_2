require 'sinatra'
require 'csv'
require 'shotgun'
require 'pry'

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
