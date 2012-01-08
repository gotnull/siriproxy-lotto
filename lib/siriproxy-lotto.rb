require 'cora'
require 'siri_objects'
require 'json'
require 'httparty'
require 'nokogiri'
	
class SiriProxy::Plugin::Lotto < SiriProxy::Plugin

	class Tattslotto

		def initialize(result, numbers, logo, draw, next_draw)
			# Instance variables
			@result = result
			@numbers = numbers
			@logo = logo
			@draw = draw
			@next_draw = next_draw
		end
		
		def show_result
			return @result
		end

		def show_numbers
			return @numbers
		end

		def show_logo
			return @logo
		end
		
		def show_draw
			return @draw
		end
		
		def show_next_draw
			return @next_draw
		end

	end  
	
	def initialize(config = {})
		@tatts_hostname = "http://tatts.com"
	end
	
	def get_numbers(type)
		uri = "#{@tatts_hostname}/tattersalls/results/latest-results?product=#{type}"
		doc = Nokogiri::HTML(open(uri))

		@winning_numbers = nil
		@winning_numbers = Array.new
		@draw = ""
		@next_draw = ""
		
		results = doc.css("div.resultDiv").map do |result|
			@draw = result.at_css("span.resultHeadingDrawDateSpn").text.strip
		end
		
		next_draw_div = doc.css("div.resultDiv").map do |result|
			@next_draw = result.at_css("span.resultNextDrawCaptionSpn a").text.strip
		end
		
		result_wrapper = doc.css("div.resultNumberWrapperDiv").map do |result|
			@winning_numbers.push(result.at_css("span.resultNumberSpn").text.strip)
		end

		logo = doc.css("div.resultNextDrawDiv").map do |result|
			@logo_url = result.at_css("span.resultNextDrawCaptionSpn img").attribute("src").to_s
		end

		numbers = nil
		supps = nil
		result = nil
		logo = nil
		supp_type = nil
		
		if (type == "Tattslotto")
			numbers = @winning_numbers.first(6).join(", ")
			supps = @winning_numbers.last(2).join(" and ")
			supp_type = "supplementaries"
		elsif (type == "Powerball")
			numbers = @winning_numbers.first(5).join(", ")
			supps = @winning_numbers.last
			supp_type = "powerball"
		end
		
		result = "The winning #{type} numbers for #{@draw.split(", ")[1]} are: #{numbers} and the #{supp_type}: #{supps}. Good luck!"
		logo = "#{@tatts_hostname}#{@logo_url}"
		
		t = Tattslotto.new(result, numbers, logo, @draw, @next_draw)
		
		return t
	end

	# Example: "Siri, what are the Tattslotto numbers?"
	listen_for /(tattslotto|powerball|super66) numbers/i do |type|

		say "One moment:"

		Thread.new {
		
			t = get_numbers(type)
			
			say t.show_result
		
			object = SiriAddViews.new

			object.make_root(last_ref_id)

			answer = SiriAnswer.new("Next Draw: #{t.show_next_draw}", [
				SiriAnswerLine.new("logo", "#{t.show_logo}")
			])

			object.views << SiriAnswerSnippet.new([answer])

			send_object object
				
			request_completed
			
		}

	end

end
