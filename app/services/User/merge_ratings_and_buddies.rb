class User

  class MergeRatingsAndBuddies

    def self.call(main, sub)
      merger = new(main, sub)
    end

    private

    def initialize(main, sub)
      @main = main
      @sub = sub
      merge_ratings_and_buddies
    end

    def merge_ratings_and_buddies
      @sub.ratings.each { |rating| rating.update!(user_id: @main.id) }
      @sub.buddies.each { |buddy| buddy.update!(user_id: @main.id)}
    end

  end

end
