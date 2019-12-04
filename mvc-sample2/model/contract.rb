class Contract < ApplicationRecord
  include SoftDeletable
  
  SECTION_TYPE = %w{parties definitions clauses free_text}

  belongs_to :chennel_partner
  
  validates :title, :sub_title, :body, presence: true
  
  before_create :check_script

  scope :completed, -> {where(complete: true)}
  scope :incomplete, -> {where.not(complete: true)}
  
  private
    def check_script
      i = self.body.index '<javascript>'
      j = self.body.index '</javascript>'

      self.body&.gsub!(self.body[i..j+12], '') if i&&j 
    end
end
