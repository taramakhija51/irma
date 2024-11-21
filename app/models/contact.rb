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
end
