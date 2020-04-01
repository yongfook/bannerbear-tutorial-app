class Article < ApplicationRecord
	validates_presence_of :url
	validates_uniqueness_of :url
	validates :url, format: URI::regexp(%w[http https])
	validate :is_wikipedia_url
	before_save :grab_html

	def title
		Nokogiri::HTML.parse(self.html).at('h1').text
	end

	def image
		"https:" + Nokogiri::HTML.parse(self.html).at('.infobox img')['srcset'].split('1.5x, ').last.split(' 2x').first
	end

	def first_sentence
		Nokogiri::HTML.parse(self.html).at('.mw-parser-output p').text.split(".").first
	end

	def grab_html
		response = HTTParty.get(self.url)
		return if response.code != 200
		self.html = response.body
	end

	def is_wikipedia_url
		uri = URI.parse(url.downcase)
		if uri.host
			return true if uri.host.match /[a-z]{2}\.wikipedia\.org/
			errors.add(:url, "must be an article on wikipedia.org")
		end
	end

end
