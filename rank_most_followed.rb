#!/usr/bin/env ruby

require_relative 'config'

username = Config::USERNAME
client_db = Config::mongo_client

def percentage(done, total)
  percent = (done.to_f/total*100).round(0)
  a = percent.to_i.times.map { '=' }.join
  b = (100 - percent.to_i).times.map { ' ' }.join
  print "Percentage: #{percent}% -> #{done} of #{total}"
  print "     [#{a}#{b}] \r"
end

following_tree = client_db[:following_tree]
the_master = following_tree.find({ name: username })
following = the_master.first[:following]

total = following.inject(0) { |acc, e| acc + e[:following].count + 1 }


r = {}
i = 0

puts "Arranging elements of DB..."
following.each do |f|
  i += 1
  f[:following].each do |followed|
    i += 1
    percentage(i, total)
    unless r[followed[:name]]
      r[followed[:name]] = { followers: [f[:name]], count: 1}
    else
      r[followed[:name]][:followers] << f[:name]
      r[followed[:name]][:count] += 1
    end
  end
end

puts "\n\nOrdering element and preparing record to DB..."
total = r.count
i = 0
rank_following_results = r.sort_by do |name, prop| 
  prop[:count] 
end.reverse.map do |e| 
  { name: e[0], count: e[1][:count], followers: e[1][:followers] } 
end.select do |e|
  i += 1
  percentage(i, total)
  e[:count] > 1
end


puts "\n\nDone! Go check the Database"

the_master_obj = { 
  name: username,
  rank_following: []
}

rank_following = client_db[:rank_following]
the_master = rank_following.find({ name: username })

if the_master.count == 0
  rank_following.insert_one(the_master_obj)
  the_master = rank_following.find({ name: username })
end

the_master.update_one(
  { "$set" => { rank_following: rank_following_results }}
)

attrs = { color:'red', shape: 'dot' }

root_node = {}
root_node[username.to_sym] = attrs.merge(label: 'Jose')

nodes = {}

rank_following_results.each do |rf|
  nodes[rf[:name].downcase.to_sym] = attrs.merge(label: rf[:name])
end

edges = {}
edges_inside = {}

nodes.keys.each do |name|
  edges_inside[name] = {}
end
edges[username.to_sym] = edges_inside

data = {
  nodes: root_node.merge(nodes),
  edges: edges
}

data_file = File.new('page/js/data_results.js', 'w')
data_file.puts "var data = #{data.to_json};"
