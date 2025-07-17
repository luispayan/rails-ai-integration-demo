class Product < ApplicationRecord
  def formatted_price
    "$%.2f" % price
  end
end
