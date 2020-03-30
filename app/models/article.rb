class Article < ApplicationRecord
	validates_uniqueness_of :url
	validates :url, format: URI::regexp(%w[http https])
	validate :is_wikipedia_url

	def is_wikipedia_url
		uri = URI.parse(url.downcase)
		if uri.host
			return true if uri.host.match /[a-z]{2}\.wikipedia\.org/
			errors.add(:url, "must be an article on wikipedia.org")
		end
	end

end
