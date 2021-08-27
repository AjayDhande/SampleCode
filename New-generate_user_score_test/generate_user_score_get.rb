require 'faraday'
require 'pry'
require 'json'
require 'byebug'

class  GenerateScore
	# Method to get Github Event API response
	def get_reponse(username)
		api_call(username)
		if @response.status == 200
			data = JSON.parse(@response.body)
		  @a,@b,@c,@d,@e,@f,@g,@h = 0,0,0,0,0,0,0,0
		  get_events_data(data)
			final_score
		else
			puts "Badrequest"
		end
	end

	def api_call(username)
		@response = Faraday.get("https://api.github.com/users/#{username}/events")
	end

  # Method to get events and score from API response
	def get_events_data(data)
		get_events_list(data)
	end

  def get_scores(data)
  	data.each do |d|
			d['type'] == "IssueEvent" ? (@a += 7) : @a += 0  
			d['type'] == "IssueCommentEvent" ? (@b += 6) : @b += 0 
			d['type'] == "PushEvent" ? (@c += 5) :  @c += 0
			d['type'] == "PullRequestReviewCommentEvent" ? (@d += 4) : @d += 0
			d['type'] == "WatchEvent" ? (@e += 3) :  @e += 0
			d['type'] == "CreateEvent" ? (@f += 2) :  @f += 0
      d['type'] == "PullRequestEvent" ? (@g += 2) : @g += 0 
		  d['type'] == "DeleteEvent" ? (@h += -1) :  @h += 0
		end
  end

	def get_events_list(data)
		get_scores(data)
		events_list = data.map{|d| d['type']}.uniq
		events_list.each do |e|
			e == "IssueEvent" ? (puts "Event: #{e}" ; puts "score: #{@a}") : (print "")
			e == "IssueCommentEvent" ? (puts "Event: #{e}" ; puts "score: #{@b}") : (print "")
			e == "PushEvent" ? (puts "Event: #{e}" ; puts "score: #{@c}") : (print "")
			e == "PullRequestReviewCommentEvent" ? (puts "Event: #{e}" ; puts "score: #{@d}") : (print "")
			e == "WatchEvent" ? (puts "Event: #{e}" ; puts "score: #{@e}") : (print "")
			e == "CreateEvent" ? (puts "Event: #{e}" ; puts "score: #{@f}") : (print "")
      e == "PullRequestEvent" ? (puts "Event: #{e}" ; puts "score: #{@g}") : (print "")
		  e == "DeleteEvent" ? (puts "Event: #{e}" ; puts "score: #{@h}") : (print "")
		end
	end

	def final_score
    result = [@a,@b,@c,@d,@e,@f,@g,@h].map(&:to_i).sum
		puts "Total Score of user is: #{result}"
	end
end


generate_score = GenerateScore.new
puts "Enter your github username : "
your_user_name = gets.chomp ; puts ""
generate_score.get_reponse(your_user_name) # to pass dynamic username in API call


# Example inputs :
# username = wycats