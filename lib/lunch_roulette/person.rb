class LunchRoulette
  class Person
    attr_accessor :name, :lunchable, :previous_lunches, :features, :industry, :section, :user_id, :gender, :email
    def initialize(hash)
      @features = {}
      @lunchable = %w(true TRUE).include? hash['lunchable']
      @industry = hash['industry']
      @user_id = hash['user_id']
      @email = hash['email']
      @section = hash['section']
      @gender = hash['gender']
      @features['industry'] = config.industry_mappings[@industry].to_i
      @features['section'] = config.section_mappings[@section].to_i
      @features['gender'] = config.gender_mappings[@gender].to_i
      @name = hash['name']
      @previous_lunches = []
      if hash['previous_lunches']
        @previous_lunches = hash['previous_lunches'].split(',').map{|i| i.to_i }
        config.maxes['lunch_id'] = @previous_lunches.max if @previous_lunches && (@previous_lunches.max > config.maxes['lunch_id'].to_i)
        # Generate previous lunches to person mappings:
        @previous_lunches.map do |previous_lunch|
          config.previous_lunches[previous_lunch] ||= LunchGroup.new
          config.previous_lunches[previous_lunch].people = [config.previous_lunches[previous_lunch].people, self].flatten
        end
      end
    end

    def inspect
      return @section
      s = @name
      if @section
        s += " (#{@industry} - #{@section}"
      else
        s += " (#{@industry}"
      end
      s += ", Gender #{@gender})"
      s
    end

    def config
      LunchRoulette::Config
    end

  end
end
