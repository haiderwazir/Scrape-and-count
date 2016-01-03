class Crawler
	require 'open-uri'
	require 'nokogiri'
	require 'net/https'
	require 'thread'

	@@total_links = 0
	@@result = []
	@@visited_links= []

	def self.crawl(url, recursive = 0)
		page = open_page(url)
		url = page.base_uri.to_s.chomp("/")
		source= Nokogiri::HTML(page)
		# check to see if still within limitations
		if !@@visited_links.include?(url) && recursive <= 2 
			if source
				@@visited_links << url

				# call method to count inputs for page and add to results
				inputs_for_page, counted_links = self.count_inputs(source, url)
				@@result << {:url=> url, :number_of_inputs=> inputs_for_page}

				# for every internal link on the page, call main function recursively. Limitations applied.
				work_q2 = Queue.new
				@@total_links += 1
				counted_links.uniq.each{|url| work_q2 << url}
				workers_2 = (0..7).map do
				    Thread.new do
				    	begin
					        while link = work_q2.pop(true)
					            begin
					            	if @@total_links <= 50
										self.crawl(link, recursive+1) 
									end
								rescue => e
								end
							end
						rescue ThreadError
						end
					end
				end
				workers_2.map(&:join)
			end
		end
		if recursive == 0
			@@result.each do |page|
				puts "#{page[:url]} - #{page[:number_of_inputs]}"
			end
			return @@result[0][:number_of_inputs]
		end
	end

	def self.count_inputs(source,url)
		inputs_for_page = source.search("input").count
		hrefs = source.search("a").collect { |link| link['href'] }
		counted_links = Array.new
		if hrefs && hrefs.size > 0
			work_q1 = Queue.new
		    hrefs.uniq[0..49].each{|href| work_q1 << href}
		    workers_1 = (0..25).map do
			    Thread.new do
			    	begin
				        while href = work_q1.pop(true)
			        		href= href.chomp("/")
			        		# call method to check to see if listed link is correct and internal
							link= self.check_uri(href, url)
							if link 
								link= link.chomp("/")
								source_new= Nokogiri::HTML(open_page(link))
								number_of_inputs = source_new ? source_new.search("input").count : 0
								print "."
								inputs_for_page += number_of_inputs unless counted_links.include?(link)
								counted_links << link
							end
					end
					rescue ThreadError
					end
				end
			end
			workers_1.map(&:join)
		end
		return inputs_for_page, counted_links
	end

	def self.check_uri(latest, original)
		return nil if latest =~ /^#/ || latest =~ /^javascript:/ || latest =~ /^mailto:/ || latest =~ /^\.\.\// || latest == nil
		uri = URI(latest)
		uri_src= URI(original)
		if latest =~ /\A#{URI::regexp(['http', 'https'])}\z/
			return latest if uri.host == uri_src.host
		elsif latest == "/" 
			return uri_src.scheme + '://' + uri_src.host
		elsif uri.path
		    uri_path_parts = uri.path.split '/'
		    uri_path_parts.shift
		    return uri_src.scheme + '://' + uri_src.host + '/' + uri_path_parts.join('/')
		end
	end

	def self.open_page(url)
		open(url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
	end
	# ruby -r "./crawler.rb" -e "Crawler.crawl 'url'" to run from CL
end





