class Movie < ActiveRecord::Base
  def self.with_ratings
    %w(G PG PG-13 NC-17 R)
  end
end