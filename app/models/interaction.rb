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
end
