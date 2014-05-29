require 'pg'
require 'sinatra'

require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname: 'slacer_news')

    yield(connection)

  ensure
    connection.close
  end
end

def find_articles

end


def article_exists(params)
  errors = []
  articles_pg = db_connection("SELECT * FROM articles;")
  articles = articles_pg.to_a
  articles.each do |article|
    if article['url'] == params
      errors << 1
    end
  end
  errors
end


get '/' do
@articles = db_connection("SELECT * FROM articles;")
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
    PLACEHOLDER(params[:url],params[:new_article],params[:description], params[:name])

    redirect '/'
  end
end
