# == Schema Information
#
# Table name: contacts
#
#  id                       :bigint           not null, primary key
#  communication_frequency  :integer
#  current_employer         :string
#  date_first_met           :date
#  embedding                :text
#  first_name               :string
#  how_met                  :string
#  industry                 :string
#  integer                  :string
#  last_name                :string
#  most_recent_contact_date :date
#  notes                    :string
#  partner                  :string
#  role                     :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  introduced_by_id         :string
#  user_id                  :integer
#
class Contact < ApplicationRecord
  has_many(:interactions,
  class_name: "Interaction",
  foreign_key: "contact_id"
)

has_many(:events,
through: :interactions,
source: :event
)


belongs_to(:user,
class_name: "User",
foreign_key: "user_id"
)
validates :user_id, presence: true
serialize :embedding, Array
end
