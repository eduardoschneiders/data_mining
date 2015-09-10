require 'rubygems'
require 'twitter'
require 'google_chart'
require 'dotenv'
require 'pry'
require 'mongo'

Dotenv.load

class AppConfig
  USERNAME= 'eduschneiders'

  def self.twitter_client
    @twitter_client ||= Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV['DM_TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['DM_TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['DM_TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['DM_TWITTER_ACCESS_TOKEN_SECRET']
    end
  end

  def self.mongo_client
    @mongo_client ||= Mongo::Client.new(['localhost:27017'], database: 'data_mining_test')
  end

  def self.percentage(done, total)
    percent = (done.to_f/total*100).round(0)
    a = percent.to_i.times.map { '=' }.join
    b = (100 - percent.to_i).times.map { ' ' }.join
    print "Percentage: #{percent}% -> #{done} of #{total}"
    print "     [#{a}#{b}] \r"
  end
end

