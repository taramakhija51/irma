# == Schema Information
#
# Table name: events
#
#  id             :bigint           not null, primary key
#  event_date     :date
#  event_location :string
#  event_type     :string
#  intention      :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :integer
#
class Event < ApplicationRecord
  has_many(:interactions,
    class_name: "Interaction",
    foreign_key: "event_id"
  )

  has_many(:contacts,
  through: :interactions,
  source: :contact
  )

end
