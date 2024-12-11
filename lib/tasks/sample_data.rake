require 'faker'

namespace :db do
  desc "Add sample data to the database"
  task :sample_data => :environment do
    user = User.first_or_create!(
      email: "tmakhija51@gmail.com", # You can replace this with a more dynamic email generator if needed
      password: "password" # Replace with a valid password setup for your User model
    )
    60.times do
      contact = Contact.new
      contact.user = user
      contact.communication_frequency = rand(1..55)
      contact.current_employer = Faker::Company.name
      contact.date_first_met = Time.at(rand(Time.parse("2015-11-16 14:40:34").to_i..Time.parse("2024-12-01 14:40:34").to_i))
      contact.most_recent_contact_date = Time.at(rand(Time.parse("2022-11-16 14:40:34").to_i..Time.parse("2024-12-01 14:40:34").to_i))
      contact.first_name = Faker::Name.first_name
      contact.last_name = Faker::Name.last_name

      location = ["plane", "coffee shop", "business dinner", "seminar", "mutual friend's home", "hotel", "work trip", "sister-in-law's baby shower"].sample
      contact.how_met = "Met at a #{location} while discussing our mutual interest in trying to #{Faker::Company.bs}"
      contact.industry = Faker::IndustrySegments.industry
      contact.role = Faker::Job.title
      contact.partner = Faker::Name.first_name

      interest_type = [Faker::Game, Faker::Movie, Faker::Book, Faker::DcComics].sample
      contact.notes = "Loves talking about #{interest_type.title}"

      if contact.save
        puts "Contact created: #{contact.first_name} #{contact.last_name}"
      else
        puts "Failed to create contact: #{contact.errors.full_messages.join(', ')}"
      end
    end
  end
end

   
