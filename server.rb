require "sinatra"
require "pg"

configure :development do
  set :db_config, { dbname: "movies" }
end

configure :test do
  set :db_config, { dbname: "movies_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get "/actors" do
  @actors = db_connection do |conn|
    conn.exec("
    SELECT actors.id, actors.name
    FROM actors
    ORDER BY actors.name ASC
    ")
  end
  erb :'actors/index'
end

get "/actors/:id" do
  @actor_id = params[:id]
  @actor_info = db_connection do |conn|
  conn.exec("
    SELECT actors.name AS actor_name, cast_members.character AS role, movies.title AS movie_title, movies.id AS movie_id
    FROM actors
    JOIN cast_members ON actors.id = cast_members.actor_id
    JOIN movies ON movies.id = cast_members.movie_id
    WHERE actors.id = #{@actor_id}
    ")
  end
  erb :'actors/show'
end

get "/movies" do
  @movies = db_connection do |conn|
    conn.exec("
    SELECT movies.id, movies.title, movies.year, movies.rating, genres.name AS genre, studios.name AS studio
    FROM movies
    LEFT JOIN genres ON genres.id = movies.genre_id
    LEFT JOIN studios ON studios.id = movies.studio_id
    ORDER BY movies.title ASC
    ")
  end
  erb :'movies/index'
end

get "/movies/:id" do
  @movie_id = params[:id]
  @movie_info = db_connection do |conn|
    conn.exec("
    SELECT movies.id, movies.title, movies.year, movies.rating, genres.name AS genre, studios.name AS studio, cast_members.character AS role, actors.name AS actor_name, actors.id AS actor_id
    FROM movies
    LEFT JOIN genres ON genres.id = movies.genre_id
    LEFT JOIN studios ON studios.id = movies.studio_id
    JOIN cast_members ON movies.id = cast_members.movie_id
    JOIN actors ON actors.id = cast_members.actor_id
    WHERE movies.id = #{@movie_id}
    ")
  end
  erb :'movies/show'
end
