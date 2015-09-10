#!/usr/bin/env ruby

require_relative 'config'

client_db = AppConfig::mongo_client

def update_db(record, following)
  the_master.update_one(
    { "$set" => { resources: following }}
  )
end

resources = client_db[:resources]

done = 0
total = resources.find.count
resources.find.each do |resource|
  unless resource[:all_hashtags]
    if resource[:tweets]
      all_hashtags = resource[:tweets].map {|t| t[:hashtags] }.flatten.uniq

      unless all_hashtags.empty?
        resources.find(
          { name: resource[:name]}
        ).update_one(
          { "$set" => { all_hashtags: all_hashtags }}
        )
      end
    end
  end
  done += 1
  AppConfig::percentage(done, total)
end

puts "\n\nDone!"
