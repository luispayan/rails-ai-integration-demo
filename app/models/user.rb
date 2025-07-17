class User < ApplicationRecord
  has_many :orders, dependent: :destroy
  has_many :products, through: :orders

  validates :name, :email, :gender, :age, :country, :state, :signup_date, presence: true
  validates :email, uniqueness: true
  validates :age, numericality: { greater_than_or_equal_to: 0 }
end
