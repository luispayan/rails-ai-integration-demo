require 'faker'
require 'net/http'

PRODUCTS_COUNT = ENV['PRODUCTS_COUNT'] || 194
POSTS_LIMIT = ENV['POSTS_LIMIT'] || 100
FAKE_API_URL = ENV['FAKE_API_URL'] || 'https://dummyjson.com'

# Clear existing products
Order.destroy_all
User.destroy_all
Product.destroy_all

response = Net::HTTP.get(URI(FAKE_API_URL + "/products?limit=#{PRODUCTS_COUNT}&select=title,description,price,tags,images"))
products = JSON.parse(response)['products']
products.each do |product_data|
  Product.create!(
    name: product_data['title'],
    description: product_data['description'],
    price: product_data['price'],
    tags: product_data['tags'].join(', '),
    image_url: product_data['images'].first
  )
end

# Clear existing products
Post.destroy_all

response = Net::HTTP.get(URI(FAKE_API_URL + "/posts?limit=#{POSTS_LIMIT}&select=title,body,tags,views"))
posts = JSON.parse(response)['posts']
posts.each do |post_data|
  Post.create!(
    title: post_data['title'],
    body: post_data['body'],
    tags: post_data['tags'].join(', '),
    views: post_data['views']
  )
end

genders = [ "male", "female", "prefer not to say" ]

Product.all.each do |product|
  5.times do
    user = User.create!(
      name: Faker::Name.name,
      email: Faker::Internet.unique.email,
      gender: genders.sample,
      age: rand(18..65),
      country: Faker::Address.country,
      state: Faker::Address.state,
      signup_date: Faker::Date.between(from: 2.years.ago, to: Date.today)
    )

    rand(1..4).times do
      Order.create!(
        user: user,
        product: product,
        quantity: rand(1..10)
      )
    end
  end
end

puts "✅ Seeded #{PRODUCTS_COUNT} products"
