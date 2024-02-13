class ActionText::Content::Filter
  class << self
    def apply(content)
      filter = new(content)
      filter.applicable? ? filter.apply : content
    end
  end

  def initialize(content)
    @content = content
  end

  def applicable?
    raise NotImplementedError
  end

  def apply
    raise NotImplementedError
  end

  private
    attr_reader :content
    delegate :fragment, to: :content
end
