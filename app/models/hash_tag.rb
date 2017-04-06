class HashTag < ApplicationRecord
  has_many :hash_tag_posts
  has_many :posts, through: :hash_tag_posts

  def self.regexp
    /#([a-z0-9\w]+\b)/i
  end

  # return lower case array of matching hashtags in the strong provided.
  def self.find_in(string)
    return [] if string.blank?

    string.scan(regexp).flatten.map(&:downcase)
  end

  def self.find_or_create(tag)
    existing = find_by(tag: tag)
    return existing if existing.present?
    new_tag = create(tag: tag)
    new_tag
  end
end
