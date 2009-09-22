require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'test/unit'


# ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'

require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))



# config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")


# ActiveRecord::Base.establish_connection(config['test'])

ActiveRecord::Base.establish_connection({
  :adapter => 'postgresql',
  :database => 'test2',
  :username => 'postgres',
  :password => 'postgres',
  :host => 'localhost',
})



load(File.dirname(__FILE__) + "/schema.rb")

class MigrationTest < ActiveRecord::Migration
end