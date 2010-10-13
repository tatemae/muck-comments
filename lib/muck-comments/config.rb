module MuckComments
  
  def self.configuration
    # In case the user doesn't setup a configure block we can always return default settings:
    @configuration ||= Configuration.new
  end
  
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :send_email_for_new_comments  # This will send out an email to each user that has participated in a comment thread.  The default email is basic and only includes the body
                                                # of the comment.  Add new email views to provide a better email for you users.  They can be found in app/views/comment_mailer/new_comment.html.erb
                                                # and app/views/comment_mailer/new_comment.text.erb
   
    attr_accessor :sanitize_content             # Turns sanitize off/on for comments. We highly recommend leaving this on.
    
    def initialize
      self.send_email_for_new_comments = false
      self.sanitize_content = true
    end
    
  end
end