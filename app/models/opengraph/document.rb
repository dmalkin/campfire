require "nokogiri"

class Opengraph::Document
  attr_accessor :html

  def initialize(html)
    @html = Nokogiri::HTML(html)
  end

  def opengraph_attributes
    @opengraph_attributes ||= extract_opengraph_attributes
  end

  private
    def extract_opengraph_attributes
      opengraph_tags = html.xpath("//*/meta[starts-with(@property, \"og:\") or starts-with(@name, \"og:\")]").map do |tag|
        key = tag.key?("property") ? "property" : "name"
        [ tag[key].gsub("og:", "").to_sym, tag["content"] ] if tag["content"].present?
      end

      Hash[opengraph_tags.compact].slice(*Opengraph::Metadata::ATTRIBUTES)
    end
end
