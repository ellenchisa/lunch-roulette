class LunchRoulette
  class Config

    def initialize
      @@config = YAML::load(File.open('config/mappings_and_weights.yml'))
      @@maxes = {}
      @@previous_lunches = {}
    end

    def self.weights
      @@config['weights']
    end

    def self.min_lunch_group_size
      @@options[:min_lunch_group_size] || @@config['min_lunch_group_size']
    end

    def self.match_thresholds
      (2..min_lunch_group_size)
    end

    def self.section_mappings
      @@config['section_mappings']
    end

    def self.industry_mappings
      @@config['industry_mappings']
    end

     def self.gender_mappings
      @@config['gender_mappings']
    end

    def self.maxes=(m)
      @@maxes = m
    end

    def self.maxes
      @@maxes
    end

    def self.previous_lunches=(p)
      @@previous_lunches = p
    end

    def self.previous_lunches
      @@previous_lunches
    end

    def self.options=(o)
      @@options = o
    end

    def self.options
      @@options
    end

  end
end
