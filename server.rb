require 'sinatra'
require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname: 'slacker_news')

    yield(connection)

  ensure
    connection.close
  end
end

def find_articles

end


def article_exists(params)
  errors = []
  articles_pg = db_connection do |conn|
  conn.exec("SELECT * FROM articles;")
  end
  articles = articles_pg.to_a
  articles.each do |article|
    if article['url'] == params
      errors << 1
    end
  end
  errors
end


get '/' do
@articles = db_connection do |conn|
  conn.exec("SELECT * FROM articles;")
end
@articles = @articles.to_a

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
    url = params[:url]
    headline = params[:new_article]
    description = params[:description]
    name = params[:name]
    insert = ("INSERT INTO articles (name, headline, url, description) VALUES ($1, $2, $3, $4);")
    articles_pg = db_connection do |conn|
    conn.exec_params(insert, [name , headline, url, description])
    end

    redirect '/'
  end
end

get '/articles/:id/comments' do
  @articles = db_connection do |conn|
    conn.exec("SELECT * FROM articles WHERE id = '#{params[:id]}';")
  end
@articles = @articles.to_a
erb :comments
end
