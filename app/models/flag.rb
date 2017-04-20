class Flag < ApplicationRecord
  scope :pending, -> { where(published: true) }

  enum status: [:pending, :moderated, :post_already_moderated, :post_deleted]

  belongs_to :user
  belongs_to :post

  validates :reason, length: { maximum: 500 }

  before_create { self.status = :post_already_moderated if post.moderated? }
  after_create { FlagMailer.admin_alert(self).deliver_later if is_pending? }

  def is_pending?
    status.to_s == 'pending'
  end
end
