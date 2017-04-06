class HashTagCleaningService
  attr_reader :tags

  def initialize(tags)
    @tags = tags
  end

  def clean_up
    tags.each do |tag|
      model = HashTag.find_by(tag: tag)
      next unless model

      model.destroy if model.hash_tag_posts.count.zero?
    end
  end
end
