require 'faraday'
require 'pry'
require 'json'
require 'byebug'

class  GenerateScore
	# Method to get Github Event API response
	def get_reponse(username)
		response = Faraday.get("https://api.github.com/users/#{username}/events")
		if response.status == 200
			data = JSON.parse(response.body)
		  @a,@b,@c,@d,@e,@f,@g,@h = 0,0,0,0,0,0,0,0
		  get_events(data)
			result = [@a,@b,@c,@d,@e,@f,@g,@h].map(&:to_i).sum
			puts result
		else
			puts "Badrequest"
		end
	end

  # Method to get events and score from API response
	def get_events(data)
		data.each do |d|
			d['type'] == "IssueEvent" ? (@a += 7; puts "IssueEvent") : @a += 0  
			d['type'] == "IssueCommentEvent" ? (@b += 6; puts "IssueCommentEvent") : @b += 0 
			d['type'] == "PushEvent" ? (@c += 5; puts "PushEvent") :  @c += 0
			d['type'] == "PullRequestReviewCommentEvent" ? (@d += 4; puts "PullRequestReviewCommentEvent") : @d += 0
			d['type'] == "WatchEvent" ? (@e += 3; puts "WatchEvent") :  @e += 0
			d['type'] == "CreateEvent" ? (@f += 2; puts "CreateEvent") :  @f += 0
      d['type'] == "PullRequestEvent" ? (@g += 2; puts "PullRequestEvent") : @g += 0 
		  d['type'] == "DeleteEvent" ? (@h += -1; puts "DeleteEvent") :  @h += 0
		end
	end
end

generate_score = GenerateScore.new
puts "Enter your github username : "
your_user_name = gets.chomp
generate_score.get_reponse(your_user_name) # to pass dynamic username in API call
