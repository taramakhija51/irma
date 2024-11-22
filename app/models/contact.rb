# == Schema Information
#
# Table name: contacts
#
#  id                       :bigint           not null, primary key
#  communication_frequency  :integer
#  current_employer         :string
#  date_first_met           :date
#  how_met                  :string
#  industry                 :string
#  integer                  :string
#  most_recent_contact_date :date
#  notes                    :string
#  partner                  :string
#  role                     :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  introduced_by_id         :string
#  user_id                  :string
#
class Contact < ApplicationRecord
  has_many(:interactions,
  class_name: "Interaction",
  foreign_key: "contact_id"
)

belongs_to(:user,
class_name: "User",
foreign_key: "user_id"
)
attr_accessor :first_name, :last_name, :date_first_met, :current_employer, :partner, :most_recent_contact_date, :communication_frequency, :industry, :role, :user_id, :introduced_by_id, :how_met, :notes
end
