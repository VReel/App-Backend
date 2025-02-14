class Post < ApplicationRecord
  include S3Urls
  include LockedIncrementDecrement
  acts_as_paranoid

  MAX_HASH_TAGS = 30

  belongs_to :user
  has_many :hash_tag_posts
  has_many :hash_tags, through: :hash_tag_posts
  has_many :comments, -> { order('created_at ASC') }
  has_many :likes
  has_many :flags
  has_many :flagged_by_users, through: :flags, source: :user

  validates :original_key, presence: true
  validates :thumbnail_key, presence: true
  validates :user_id, presence: true
  validates :caption, length: { maximum: 500 }
  validate :valid_keys

  before_update { self.edited = true if caption_changed? }
  before_save { set_hash_tags! }
  # rubocop:disable SkipsModelValidations
  before_save { flags.pending.update_all(status: :moderated) if moderated && moderated_changed? }
  # rubocop:enable SkipsModelValidations

  before_destroy do
    PostDeletionService.new(id).delay.delete!
  end

  after_create { user.locked_increment(:post_count) }
  after_destroy { user.locked_decrement(:post_count) }

  def delete_s3_resources
    s3_deletion_service = S3DeletionService.new

    [thumbnail_key, original_key].each { |key| s3_deletion_service.delete(key) }
  end

  def s3_folder
    user.unique_id
  end

  def hash_tag_values
    hash_tags.map(&:tag).first(MAX_HASH_TAGS)
  end

  def hash_tags_in_comments
    HashTag.find_in(comments.where(has_hash_tags: true).limit(MAX_HASH_TAGS).map(&:text).join(' '))
  end

  def set_hash_tags!
    updated_hash_tag_values = HashTag.find_in(caption).first(MAX_HASH_TAGS)
    updated_hash_tag_values += hash_tags_in_comments if updated_hash_tag_values.size < MAX_HASH_TAGS
    updated_hash_tag_values.uniq!

    new_hash_tags = updated_hash_tag_values - hash_tag_values
    deleted_hash_tags = hash_tag_values - updated_hash_tag_values

    add_hash_tags(new_hash_tags)
    remove_hash_tags(deleted_hash_tags) if deleted_hash_tags.any?
  end

  def add_hash_tags(tags)
    tags.each do |tag|
      hash_tag = HashTag.find_or_create(tag)
      hash_tags << hash_tag
    end
  end

  def remove_hash_tags(tags)
    hash_tag_posts.joins(:hash_tag).where('hash_tags.tag in (?)', tags).delete_all
    hash_tags.reload
    # Create job to remove hash tags that are no longer used.
    HashTagCleaningService.new(tags).delay.clean_up
  end
end
