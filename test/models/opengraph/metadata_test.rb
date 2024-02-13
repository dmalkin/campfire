require "test_helper"

class Opengraph::MetadataTest < ActiveSupport::TestCase
  test "successful fetch" do
    WebMock.stub_request(:get, "https://www.example.com/").to_return(status: 200, body: "<html><head><meta property=\"og:url\" content=\"https://example.com\"><meta property=\"og:title\" content=\"Hey!\"><meta property=\"og:description\" content=\"desc..\"><meta property=\"og:image\" content=\"https://example.com/image.png\"></head></html>", headers: { content_type: "text/html" })
    assert Opengraph::Metadata.from_url("https://www.example.com").valid?
  end

  test "missing opengraph meta tags" do
    WebMock.stub_request(:get, "https://www.example.com/").to_return(status: 200, body: "<html><head></head></html>", headers: { content_type: "text/html" })
    opengraph = Opengraph::Metadata.from_url("https://www.example.com")

    assert_not opengraph.valid?
    assert_equal [ "Title can't be blank", "Description can't be blank" ],  opengraph.errors.full_messages
  end

  test "URL uses the provided value if the returned value is missing" do
    WebMock.stub_request(:get, "https://www.example.com/").to_return(status: 200, body: "<html><head><meta property=\"og:title\" content=\"Hey!\"><meta property=\"og:description\" content=\"desc..\"><meta property=\"og:image\" content=\"https://example.com/image.png\"></head></html>", headers: { content_type: "text/html" })
    metadata = Opengraph::Metadata.from_url("https://www.example.com")

    assert metadata.valid?
    assert_equal "https://www.example.com", metadata.url
  end

  test "URL uses the provided value if the returned value is invalid" do
    WebMock.stub_request(:get, "https://www.example.com/foo").to_return(status: 200, body: "<html><head><meta property=\"og:url\" content=\"/foo\"><meta property=\"og:title\" content=\"Hey!\"><meta property=\"og:description\" content=\"desc..\"><meta property=\"og:image\" content=\"https://example.com/image.png\"></head></html>", headers: { content_type: "text/html" })
    metadata = Opengraph::Metadata.from_url("https://www.example.com/foo")

    assert metadata.valid?
    assert_equal "https://www.example.com/foo", metadata.url
  end

  test "missing response body" do
    WebMock.stub_request(:get, "https://www.example.com/").to_return(status: 403, body: "", headers: { content_type: "text/html" })
    assert_not Opengraph::Metadata.from_url("https://www.example.com").valid?
  end

  test "non html response" do
    WebMock.stub_request(:get, "https://www.example.com/image").to_return(status: 200, body: "[blob]", headers: { content_type: "image/jpeg" })
    assert_not Opengraph::Metadata.from_url("https://www.example.com/image").valid?
  end
end
