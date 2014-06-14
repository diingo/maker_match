require 'active_model'
require 'active_record'
require 'active_record_tasks'
require 'pry-debugger'
require 'yaml'
require 'solid_use_case'
# this library allows us to generate a unique random id for sessions
require 'securerandom'
require 'vcr'
require 'json'
require 'geocoder'
require 'active_support/core_ext/object/blank'
# JSON
# require 'active_support/core_ext/object/json'
require 'dotenv'
Dotenv.load

require_relative 'gladiator_match/entity.rb'
require_relative 'gladiator_match/use_case.rb'

# require_relative 'gladiator_match/entities/user.rb'
Dir["#{File.dirname(__FILE__)}/gladiator_match/use_cases/*.rb"].each { |f| require(f) }
Dir["#{File.dirname(__FILE__)}/gladiator_match/database/*.rb"].each { |f| require(f) }
Dir["#{File.dirname(__FILE__)}/gladiator_match/entities/*.rb"].each { |f| require(f) }

module GladiatorMatch
  def self.db
    @__db_instance ||= Database::PostGres.new
  end
end