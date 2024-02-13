class Opengraph::Metadata
  include ActiveModel::Model

  ATTRIBUTES = %i[ title url image description ]

  attr_accessor *ATTRIBUTES

  validates_presence_of :title, :url, :description

  class << self
    def from_url(url)
      document = fetch_document(url)
      attributes = document.opengraph_attributes
      new attributes.merge(url: valid_canonical_url(attributes[:url], url))
    end

    private
      TWITTER_HOSTS = %w[ twitter.com www.twitter.com x.com www.x.com ]
      FX_TWITTER_HOST = "fxtwitter.com"

      def fetch_document(untrusted_url)
        tweet_url?(untrusted_url) ? fetch_fxtwitter_document(untrusted_url) : fetch_non_fxtwitter_document(untrusted_url)
      end

      def fetch_fxtwitter_document(untrusted_url)
        fxtwitter_url = replace_twitter_domain_for_opengraph_support(untrusted_url)

        Opengraph::Location.new(fxtwitter_url).then do |location|
          # fxtwitter.com HTML response does not include character encoding, resulting in emojis and quotes not
          # being encoded properly.
          Opengraph::Document.new(location.read.force_encoding("UTF-8"))
        end
      end

      def fetch_non_fxtwitter_document(untrusted_url)
        Opengraph::Location.new(untrusted_url).then do |location|
          Opengraph::Document.new(location.read)
        end
      end

      def valid_canonical_url(url, fallback)
        Opengraph::Location.new(url).valid? ? url : fallback
      end

      # Twitter.com and X.com do not support Opengraph at the moment.
      # Piggybacking on fxtwitter.com allows us to have twitter unfurling
      # without relying on fxtwitter.com's future availability.
      def replace_twitter_domain_for_opengraph_support(url)
        uri = URI.parse(url)
        uri.host = FX_TWITTER_HOST if uri.host.in?(TWITTER_HOSTS)
        uri.to_s
      rescue URI::InvalidURIError
        nil
      end

      def tweet_url?(url)
        uri = URI.parse(url)
        uri.host.in?(TWITTER_HOSTS) && uri.path.present? && uri.path != "/"
      rescue URI::InvalidURIError
        nil
      end
  end
end
