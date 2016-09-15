class Block < ActiveRecord::Base
  belongs_to :page
  mount_uploader :image, ImageUploader
  acts_as_list scope: :page
  before_validation :clean_html
  
  def clean_html
    allowed_tags = {
        elements: %w(a div b i p br ul ol li img), 
        attributes: {'a' => ['href', 'title'], 'img' => ['src', 'alt', 'style']}
    }
    logger.info self.content_before
    self.content = Sanitize.clean(self.content, allowed_tags)
    self.content_before = Sanitize.clean(self.content_before, allowed_tags)
    return true
  end
end
