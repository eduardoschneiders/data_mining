#!/usr/bin/env ruby

require_relative 'config'

client_db = Config::mongo_client

def update_db(record, following)
  the_master.update_one(
    { "$set" => { resources: following }}
  )
end

resources = client_db[:resources]
resources.find.each do |resource|
  unless resource[:all_hashtags]
    if resource[:tweets]
      puts "\n\n\n name: #{resource[:name]} --------------------------------- "
      all_hashtags = resource[:tweets].map {|t| t[:hashtags] }.flatten.uniq
      puts "tweets: #{all_hashtags} "

      unless all_hashtags.empty?
        resources.find(
          { name: resource[:name]}
        ).update_one(
          { "$set" => { all_hashtags: all_hashtags }}
        )
      end
    end
  end
end
