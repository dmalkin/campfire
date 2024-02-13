module ContentFilters
  TextMessagePresentationFilters = ActionText::Content::Filters.new(ContentFilters::RemoveSoloUnfurledLinkText)
end
