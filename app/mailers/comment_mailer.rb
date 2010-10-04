class CommentMailer < ActionMailer::Base
  
  def new_comment(comment)
    if comment.user
      display_name = comment.user.display_name
    else
      display_name = I18n.t('muck.comment.anonymous')
    end
    @comment = comment
    @display_name = display_name
    mail(:to => emails_for_comment(comment), :subject => I18n.t('muck.comments.new_comment_email_subject', :name => display_name, :application_name => MuckEngine.configuration.application_name)) do |format|
      format.html
      format.text
    end
  end
  
  protected
    def emails_for_comment(comment)
      emails = []
      comment.root.self_and_descendants.each do |c|
        emails << c.user.email unless emails.include?(c.user.email) if c.user
      end
      emails
    end
    
end