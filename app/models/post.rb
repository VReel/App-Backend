class Post < ApplicationRecord
  include S3Urls
  include IncrementDecrement
  MaxHashTags = 30

  belongs_to :user
  has_many :hash_tag_posts
  has_many :hash_tags, through: :hash_tag_posts

  validates :original_key, presence: true
  validates :thumbnail_key, presence: true
  validates :user_id, presence: true
  validate :valid_keys

  before_update { self.edited = true if caption_changed? }
  before_update { set_hash_tags! }
  before_destroy { Post.delay.delete_s3_resources([thumbnail_key, original_key]) }

  after_create { increment(user, :post_count) }
  after_destroy { decrement(user, :post_count) }

  # This is a class method so doesn't rely on existence of record.
  def self.delete_s3_resources(keys)
    s3_deletion_service = S3DeletionService.new

    keys.each { |key| s3_deletion_service.delete(key) }
  end

  def s3_folder
    user.unique_id
  end

  def current_hash_tag_values
    hash_tags.map(&:tag).first(MaxHashTags)
  end

  def set_hash_tags!
    new_hash_tag_values = HashTag.find_in(caption).first(MaxHashTags)

    # Do nothing if the hash tags are the same.
    return if new_hash_tag_values == current_hash_tag_values

    new_hash_tags = new_hash_tag_values - current_hash_tag_values
    deleted_hash_tags = current_hash_tag_values - new_hash_tag_values

    add_hash_tags(new_hash_tags) if new_hash_tags.any?
    remove_hash_tags(deleted_hash_tags) if deleted_hash_tags.any?
  end

  def add_hash_tags(tags)
    hash_tags.each do |hash_tag|
      tag = HashTag.find_or_create(tag)
      hash_tags << tag
    end
  end

  def remove_hash_tags(tags)
    hash_tag_posts.where('hash_tags.name in (?)', tags).delete_all
    # Create job to remove hash tags that are no longer used.
    HashTagCleaningService.new(tags).delay.clean_up
  end
end
