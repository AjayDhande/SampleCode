require 'faraday'
require 'pry'
require 'json'
require 'byebug'

class  GenerateScore
	# puts "Enter your github username"
	# USERINPUT = gets.chomp
	def get_reponse
		response = Faraday.get("https://api.github.com/users/ajaydhande/events")
		data = JSON.parse(response.body)
		data.each do |d|
		  @a = calculate(value = 7); puts "IssueEvent" if d['type'] == "IssueEvent"
		  @b = calculate(value = 6); puts "IssueCommentEvent" if d['type'] == "IssueCommentEvent"
			@c = calculate(value = 5); puts "PushEvent" if d['type'] == "PushEvent"
      @d = calculate(value = 4); puts "PullRequestReviewCommentEvent" if d['type'] == "PullRequestReviewCommentEvent"
			@e = calculate(value = 3); puts "WatchEvent" if d['type'] == "WatchEvent"
			@f = calculate(value = 2); puts "CreateEvent" if d['type'] == "CreateEvent"
      @g = calculate(value = 2); puts "PullRequestEvent" if d['type'] == "PullRequestEvent"
			@h = calculate(value = -1); puts "DeleteEvent" if d['type'] == "DeleteEvent"
		end
			result = [@a,@b,@c,@d,@e,@f,@g,@h].inject(&:+)
			puts result
	end
	def calculate(value)
    return value
	end
end

generate_score = GenerateScore.new
generate_score.get_reponse



