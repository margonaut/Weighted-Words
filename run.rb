require "sinatra"
require "pry"
require "twitter"
require "dotenv"
Dotenv.load

# create Twitter client object. Interface with Twitter after
# validating keys
client = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
end

# two methods that recursively collect all tweets by user
def collect_with_max_id(collection=[], max_id=nil, &block)
  response = yield(max_id)
  collection += response
  response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
end

def client.get_all_tweets(user)
  collect_with_max_id do |max_id|
    options = {count: 200, include_rts: true}
    options[:max_id] = max_id unless max_id.nil?
    user_timeline(user, options)
  end
end

def evaluation(tweets)
  failing_tweets = 0
  failing_words = 0
  marked_words = [{word: "just", count: 0},
                  {word: "like", count: 0},
                  {word: "maybe", count: 0},
                  {word: "perhaps", count: 0},
                  {word: "sorry", count: 0},
                  {word: "i'm no expert", count: 0},
                  {word: "i wouldn't know", count: 0},
                  {word: "i guess", count: 0},
                  {word: "actually", count: 0},
                  {word: "i mean", count: 0},]
  tweets.each do |tweet|
    passing = true
    marked_words.each do |wordinfo|
      if tweet.text.downcase.include?(wordinfo[:word])
        wordinfo[:count] += 1
        failing_words += 1
        passing = false
      else
      end
    end
    if passing == false
      failing_tweets += 1
    end
  end
  evaluation = [failing_tweets, failing_words, marked_words]
end

# -------------------------------------

get '/' do
  erb :index
end

get 'user/:username' do
  user = client.user(params[:username])
  tweets = client.get_all_tweets(user)
  evaluation = evaluation(tweets)
  erb :show, locals: { user: user, tweets: tweets, evaluation: evaluation }
end

# puts "choose username"
# username = gets.chomp
# user = client.user(username)
# tweets = client.get_all_tweets(user)
# puts evaluation(tweets)

# options = { count: 10, include_rts: false }
# results = client.user_timeline("theebeastmaster", options)
# anna = client.user("acsimba")

# evaluation.count("like")

# class Evaluation
#   attr_accessor :tweets :evaluation, :final_score
#   def initialize(username, tweets)
#     @username = username
#     @tweets = tweets
#     @evaluation = words_report
#     @final_score = -1
#   end
#
#   def count(word)
#
#   end
#
#   def words_report
#     # returns hash
#   end
# end