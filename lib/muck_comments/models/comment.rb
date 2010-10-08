require 'nested_set'
# include MuckComments::Models::MuckComment
module MuckComments
  module Models
    module MuckComment
      extend ActiveSupport::Concern
    
      included do
        
        acts_as_nested_set :scope => [:commentable_id, :commentable_type]
        validates_presence_of :body
        belongs_to :user
        belongs_to :commentable, :polymorphic => true, :counter_cache => 'comment_count', :touch => true

        scope :by_newest, :order => "comments.created_at DESC"
        scope :by_oldest, :order => "comments.created_at ASC"
        scope :newer_than, lambda { |*args| where("comments.created_at > ?", args.first || 1.week.ago) }
        scope :by_user, lambda { |*args| where('comments.user_id = ?', args.first) }
        
        before_save :sanitize_attributes if MuckComments.configuration.sanitize_content
        
        attr_protected :created_at, :updated_at
      end

      # Send an email to everyone in the thread
      def after_create
        CommentMailer.new_comment(self).deliver if MuckComments.configuration.send_email_for_new_comments
      end
      
      #helper method to check if a comment has children
      def has_children?
        self.children.size > 0 
      end

      # override this method to change the way permissions are handled on comments
      def can_edit?(user)
        return true if check_user(user)
        false
      end

      # Sanitize content before saving.  This prevent XSS attacks and other malicious html.
      def sanitize_attributes
        if self.sanitize_level
          self.body = Sanitize.clean(self.body, self.sanitize_level)
        end
      end
      
      # Override this method to control sanitization levels.
      # Currently a user who is an admin will not have their content sanitized.  A user
      # in any role 'editor', 'manager', or 'contributor' will be given the 'RELAXED' settings
      # while all other users will get 'BASIC'.
      #
      # By default the 'creator' of the content will be used to determine which level of
      # sanitization is allowed.  To change this set 'current_editor' before
      #
      # Options are from sanitze:
      # nil - no sanitize
      # Sanitize::Config::RELAXED
      # Sanitize::Config::BASIC
      # Sanitize::Config::RESTRICTED
      # for more details see: http://rgrove.github.com/sanitize/
      def sanitize_level
        return Sanitize::Config::BASIC if self.user.nil?
        return nil if self.user.admin?
        return Sanitize::Config::RELAXED if self.user.any_role?('editor', 'manager', 'contributor')
        Sanitize::Config::BASIC
      end
      
    end
  end
end
