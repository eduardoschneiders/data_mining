#!/usr/bin/env ruby

require_relative 'config'

client    = AppConfig::twitter_client
client_db = AppConfig::mongo_client


def update_db(the_master, following)
  the_master.update_one(
    { "$set" => { resources: following }}
  )
end

def collect_with_max_id(collection=[], max_id=nil, max, &block)
  response = yield(max_id)
  collection += response

  if response.empty? || max <= 0
    collection.flatten 
  else
    collect_with_max_id(collection, response.last.id - 1, max - 1,  &block)
  end
end

def client.get_all_tweets(user)
  collect_with_max_id do |max_id|
    begin
      options = { max: 3, count: 200, include_rts: true }
      options[:max_id] = max_id unless max_id.nil?

      user_timeline(user, options)
    rescue Twitter::Error::TooManyRequests => error
      time = error.rate_limit.reset_in
      breaking(time)
      retry
    end
  end
end

def build_tweet(t)
  { 
    text: t.text, 
    tweet_id: t.id,
    created_at: t.created_at, 
    hashtags: t.hashtags.map(&:text),
    links: t.uris.map { |u| u.url.to_s },
    retweet_count: t.retweet_count,
    user_mentions: t.user_mentions.map(&:screen_name),
    favorite_count: t.favorite_count
  }
end

def breaking(time)
  puts "\n"
  while time > 0
    print "Sleeping for #{time} seconds ---------------------\r"
    sleep 1
    time -= 1
  end
  puts '\nrestarting ------------'
end

def percentage(done, total)
  percent = (done.to_f/total*100).round(0)
  a = percent.to_i.times.map { '=' }.join
  b = (100 - percent.to_i).times.map { ' ' }.join
  print "Percentage: #{percent}% -> #{done} of #{total}"
  print "     [#{a}#{b}] \r"
end



resources = client_db[:resources]


# inc = 0
# loop do
#   results = resources.skip(inc).limit(10)
#   total = results.inject(0) { |acc, _| acc + 1 }
#   inc += 10
#   break if total <= 0
# end

# binding.pry
# exit

i = resources.find({ tweets: { "$exists" => true }}).count.round(0)
total = resources.find.count.round(0)

inc = 0
loop do
  results = resources.find({ tweets: { "$exists" => false } }).skip(inc).limit(10)
  inc += 10
  total_res = results.inject(0) { |acc, _| acc + 1 }
  break if total_res <= 0

  results.each do |r|
    i += 1
    puts i
    unless r[:tweets]
      begin
        # tweets = client.user_timeline(r[:name])
        tweets = client.get_all_tweets(r[:name])

        #tweet.attrs can be used insted of this object
        #But it weights much more
        all_tweets = tweets.map { |t| build_tweet(t) }

        r[:tweets] = all_tweets
        puts "\nName: #{r[:name]}"

        client_db[:resources].find(name: r[:name]).update_one({ "$set" => { tweets: all_tweets } })
      rescue Twitter::Error::TooManyRequests => error
        time = error.rate_limit.reset_in
        breaking(time)
        retry
      rescue Twitter::Error::Unauthorized, Twitter::Error::NotFound
        next
      rescue Twitter::Error::RequestTimeout
        puts '\n-------------- time out'
        sleep 10
        retry
      rescue Twitter::Error::ServiceUnavailable
        puts '\n-------------- unavailable'
        sleep 10
        retry

      end
      AppConfig::percentage(i, total)
    end
  end
end

puts "\n\nDone!"
