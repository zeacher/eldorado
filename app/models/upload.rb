class Upload < ActiveRecord::Base
  
  include PaperclipSupport
  
  belongs_to :user
  
  has_attached_file :attachment, :url => "/files/:filename", :storage => :filesystem
  
  validates_attachment_size :attachment, :less_than => 100.megabytes
  
  def is_mp3?
    %w(audio/mpeg audio/mpg).include?(attachment_content_type) ? true : false
  end
  
  private
  
  def attachment_url_provided?
    !self.attachment_url.blank?
  end
  
  def download_remote_file
    self.attachment = do_download_remote_file
    self.attachment_remote_url = attachment_url
  end
  
  def do_download_remote_file
    io = open(URI.parse(attachment_url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
  end
  
end
