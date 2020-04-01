class Article < ApplicationRecord
	validates_presence_of :url
	validates_uniqueness_of :url
	validates :url, format: URI::regexp(%w[http https])
	validate :is_wikipedia_url
	before_save :grab_html
	after_commit :post_to_bannerbear

	def title
		Nokogiri::HTML.parse(self.html).at('h1').text
	end

	def image
		"https:" + Nokogiri::HTML.parse(self.html).at('.infobox img, .thumb img')['srcset'].split('1.5x, ').last.split(' 2x').first
	end

	def first_sentence
		Nokogiri::HTML.parse(self.html).at('.mw-parser-output > p:not(.mw-empty-elt)').text.split(".").first.gsub(/\(.*\)/, "").gsub(" ,",",")
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

	def post_to_bannerbear
		return if !self.html
		payload = {
		  "template": ENV['bannerbear_template_id'],
		  "modifications": [
		    {
		      "name": "image",
		      "image_url": self.image
		    },
		    {
		      "name": "intro",
		      "text": self.first_sentence
		    },
		    {
		      "name": "title",
		      "text": self.title
		    }
		  ]
		}
		response = HTTParty.post("https://api.bannerbear.com/v2/images", {
			body: payload,
			headers: {"Authorization" => "Bearer #{ENV['bannerbear_api_key']}"}
		})
	end

end
