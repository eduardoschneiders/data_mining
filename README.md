# Data Mining with twitter
It fetch data from twitter with the Twitter gem [https://github.com/sferik/twitter](https://github.com/sferik/twitter).
The gem is a wrapper to the Twitter API [https://dev.twitter.com/overview/api](https://dev.twitter.com/overview/api)

## Steps to run 

1. ```./fetch_following.rb```
2. ```./rank_most_followed.rb```
3. ```./unique_resources.rb```
4. ```./fetch_tweets.rb```
5. ```./generate_hashtags.rb```
6. ```./generate_assimilations.rb```

## What witch one does
                                                                         
0. `./fetch_following.rb`
   Get all your followings and its followings.                            
                                                                         
1. `./rank_most_followed.rb`
   Rank the most followed in common by the people you follow              
                                                                         
2. `./unique_resources.rb`
   Creates a new collection with all people involved on the rank collection
                                                                         
3. `./fetch_tweets.rb`
   Gets all the tweets of the resources collections
                                                                         
4. `./generate_hashtags.rb`
   Generates a single array with all the tweets's hashtags of the resource
                                                                         
5. `./generate_assimilations.rb`
   Check repeated hashtags between the rank person and its followers

