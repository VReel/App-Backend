class Flag < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :reason, length: { maximum: 500 }

  after_create { FlagMailer.admin_alert(self).deliver_later }
end