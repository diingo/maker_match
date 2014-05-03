require 'pry-debugger'
require 'yaml'
require 'solid_use_case'
# this library allows us to generate a unique random id for sessions
require 'securerandom'

module GladiatorMatch
  def self.db
    @__db_instance ||= Database::InMemory.new
  end
end

require_relative 'gladiator_match/entity.rb'
require_relative 'gladiator_match/use_case.rb'

Gem.find_files("gladiator_match/database/*.rb").each { |path| require path }
Gem.find_files("gladiator_match/entities/*.rb").each { |path| require path }
Gem.find_files("gladiator_match/use_cases/*.rb").each { |path| require path }