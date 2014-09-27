class LunchRoulette
  class LunchSet

    attr_accessor :score, :groups, :valid, :previous_lunch_stats, :previous_lunches

    def initialize(staff)
      # Shuffle our incoming people:
      @lunchers = staff.shuffle
      @groups = generate_groups
      @score = @groups.map{|g| g.sum_score }.sum
      @previous_lunches = {}
      previous_lunch_stats
      @valid = valid_set?
    end

    def config
      LunchRoulette::Config
    end

    def inspect
      @groups.map.with_index{|group, index| "Group #{index + 1}: #{group.inspect}"}
    end

    #For CSV naming purposes
    def name
      Digest::MD5.hexdigest inspect.to_s
    end

    def generate_groups
      groups = []
      until @lunchers.empty?
        # First check whether we have enough people to create a new group
        if @lunchers.size < config.min_lunch_group_size
          # If we don't have enough people to do a new group
          @lunchers.size.times do
            # Randomly pick a group to put them in
            random_group = (rand groups.size)
            groups[random_group] = LunchGroup.new([groups[random_group].people, pop_luncher].flatten)
          end
        else
          # If we do have enough people to create a new group
          # Pick our minimum number of people and throw them in a group

          groups << LunchGroup.new(pop_luncher(config.min_lunch_group_size))
        end
      end
      groups.map.with_index{|g, i| g.id = config.maxes['lunch_id'].to_i + i + 1 }
      groups
    end

    def pop_luncher(n = 1)
      @lunchers.pop(n).select{|l| l.lunchable }
    end

    # For each group, find how many people have had lunch with each other previously
    # in groups of 2, 3, ... etc.
    def previous_lunch_stats
      config.match_thresholds.each do |match_threshold|
        @groups.each do |group|
          @previous_lunches[match_threshold] ||= 0
          @previous_lunches[match_threshold] += [group.previous_lunches[match_threshold]].flatten.compact.size
        end
      end
    end

    def valid_set?
      @valid = true

      # Are there any groups that have 3 people who have had lunch previously?
      if @previous_lunches[3] > 0
        @valid = false
      end

      # Are two execs having lunch with each other? (Lunch 0 is the permanent exec lunch)
      groups.map do |group|
        group.previous_lunches.values.map do |previous_lunch|
          if previous_lunch.to_a.flatten.include? 0
            @valid = false
          end
        end
      end

      # Are there any people with the same specialty in the same group?
      groups.map do |group|
        sections = group.people.map{|person| person.section }.compact
        if sections.uniq.size < 3
          @valid = false
        end
      end
      @valid
    end

  end
end
