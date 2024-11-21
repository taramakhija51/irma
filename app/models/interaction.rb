# == Schema Information
#
# Table name: interactions
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  contact_id :integer
#  event_id   :integer
#
class Interaction < ApplicationRecord
  belongs_to(:event,
  class_name: "Event",
  foreign_key: "event_id"
)

belongs_to(:contact,
class_name: "Contact",
foreign_key: "contact_id"
)
end
