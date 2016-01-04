require 'spec_helper'

# describe "crawl" do
# 	context "for https://www.reddit.com" do
# 		it "should return 549 for main url" do
# 			expect(Crawler.crawl("https://www.reddit.com")).to eq 549
# 		end
# 	end
# end

describe 'count inputs' do
	context "with no input" do
		it "should return 0" do
			source= Nokogiri.HTML('<body><div></div></body>')
			expect(Crawler.count_inputs(source, "https://www.shop2market.com")).to include(0)
		end
	end
	context "with one input" do
		it "should return 1" do
			source= Nokogiri.HTML('<body><div><input></div></body>')
			expect(Crawler.count_inputs(source, "https://www.shop2market.com")).to include(1)
		end
	end
	context "with five inputs" do
		it "should return 5" do
			source= Nokogiri.HTML('<body><div><input><input><input><input><input></div></body>')
			expect(Crawler.count_inputs(source, "https://www.shop2market.com")).to include(5)
		end
	end
end

describe 'open page' do
	it "should return temp file" do
		expect(Crawler.open_page("https://www.google.com").class).to eq Tempfile
	end
end
 
describe "check_uri" do
	context "with '/' as url" do
		it "should return the original url's home" do
			expect(Crawler.check_uri("/", "https://www.shop2market.com")).to eq "https://www.shop2market.com"
		end
	end
	context "with internal url" do
		it "should return latest url" do
			expect(Crawler.check_uri("https://www.shop2market.com/team", "https://www.shop2market.com")).to eq "https://www.shop2market.com/team"
		end
	end
	context "with external url" do
		it "should return nil" do
			expect(Crawler.check_uri("https://www.shop2market.com", "https://www.google.com")).to eq nil
		end
	end
	context "with  a partial url starting with /" do
		it "should return the complete url with original host" do
			expect(Crawler.check_uri("/privacy", "https://www.google.com")).to eq "https://www.google.com/privacy"
		end
	end
	context "urls that start with #" do
		it "should return nil" do
			expect(Crawler.check_uri("#adsf", "https://www.google.com")).to eq nil
		end
	end
	context "urls that start with javascript" do
		it "should return nil" do
			expect(Crawler.check_uri("javascript:", "https://www.google.com")).to eq nil
		end
	end
	context "urls that start with ../" do
		it "should return nil" do
			expect(Crawler.check_uri("../team:", "https://www.google.com")).to eq nil
		end
	end
	context "urls that start with mailto:" do
		it "should return nil" do
			expect(Crawler.check_uri("mailto:", "https://www.google.com")).to eq nil
		end
	end
	context "for urls with nil value" do
		it "should return nil" do
			expect(Crawler.check_uri(nil, "https://www.google.com")).to eq nil
		end
	end
end
 
