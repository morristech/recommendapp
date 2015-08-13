class Movie < ActiveRecord::Base
  validates_presence_of :imdb_id, :title
  validates_uniqueness_of :imdb_id

  has_many :user_items, :as => :item
  has_many :users, :through => :user_items

  def self.from_title(title)
    if Movie.exists?(title: title)
      Movie.find_by_title(title)
    else
      api_movie = Enceladus::Movie.find_by_title(title).first
      return nil unless api_movie
      Movie.create!(movie_params_from_api(api_movie))
    end
  end

  def self.search(title, page = 1)
    movies = []
    collection = Enceladus::Movie.find_by_title(title)
    while page <= collection.total_pages
      collection.current_page = page
      collection.results_per_page[page - 1].each do |api_movie|
        movies.append(Movie.new(movie_params_from_api(api_movie)))
      end
      page += 1
    end
    return movies
  end

  def self.popular_movies
    collection = Enceladus::Movie.popular
    api_movies = collection.results_per_page[0]
    Enumerator.new do |e|
      api_movies.each { |api_movie|
        movie = Movie.find_by_title(api_movie.original_title)
        unless movie
          movie = Movie.create!(movie_params_from_api(api_movie))
        end
        e.yield movie
      }
    end
  end

  def self.movie_params_from_api(api_movie)
    return {
      title:       api_movie.original_title,
      year:        api_movie.release_date,
      plot:        api_movie.overview,
      imdb_id:     api_movie.id,  #This isn't imdb id. TODO
      imdb_rating: api_movie.vote_average,  #Not imdb rating. TODO
      poster_url:  api_movie.poster_urls[1] #TODO
    }
  end

end
