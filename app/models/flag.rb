class Flag < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :reason, length: { maximum: 500 }
end
