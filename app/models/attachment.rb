class Attachment < ActiveRecord::Base
  belongs_to :event
  belongs_to :journal

  has_attached_file :attachment

  validates_attachment_presence :attachment
  
  attr_accessible :attachment
  
  def friendly_size
	  if (attachment.size / 1024) < 1024
      (attachment.size / 1024.0).ceil.to_s + " kB"
    else
      (attachment.size / 1048576.0).to_s[0..3] + " MB"
    end
  end
end
