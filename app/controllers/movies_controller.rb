class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.with_ratings
    @movies = Movie.all
    @ratings_to_show_hash = Hash[*@all_ratings.map {|key| [key, 1]}.flatten]
    
    if (params[:session] == "clear")
      session[:sort] = nil
      session[:ratings] = nil
    end
    
    if (params[:ratings] != nil)
      @ratings_to_show_hash = params[:ratings]
      @movies = @movies.where(:rating => @ratings_to_show_hash.keys)
      session[:ratings] = @ratings_to_show_hash
    end
    
    if (params[:sort] != nil)
      case params[:sort]
      when "title"
        @movies = @movies.order(:title)
        @class_title = "hilite bg-warning"
        session[:sort] = "title"
      when "release_date"
        @movies = @movies.order(:release_date)
        @class_release_date = "hilite bg-warning"
        session[:sort] = "release_date"
      end
    end
    
    if (params[:sort] == nil || params[:ratings] == nil)
      redirect_hash = (session[:ratings] != nil) ? Hash[*session[:ratings].keys.map {|key| ["ratings[#{key}]", 1]}.flatten] : { :ratings => @ratings_to_show_hash }
      redirect_hash[:sort] = (session[:sort] != nil) ? session[:sort] : "none"
      redirect_to movies_path(redirect_hash) and return
    end
  end 

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
