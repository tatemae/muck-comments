module ActiveRecord
  module Acts #:nodoc:
    module MuckComment #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        def acts_as_muck_comment(options = {})

          default_options = { 
            :sanitize_content => true,
          }
          options = default_options.merge(options)
          
          acts_as_nested_set :scope => [:commentable_id, :commentable_type]
          validates_presence_of :body
          belongs_to :user
          belongs_to :commentable, :polymorphic => true, :counter_cache => 'comment_count', :touch => true

          named_scope :limit, lambda { |num| { :limit => num } }
          named_scope :by_newest, :order => "comments.created_at DESC"
          named_scope :by_oldest, :order => "comments.created_at ASC"
          named_scope :recent, lambda { { :conditions => ['comments.created_at > ?', 1.week.ago] } }
          named_scope :by_user, lambda { { :conditions => ['comments.user_id  ?', user.id] } }
          
          if options[:sanitize_content]
            before_save :sanitize_attributes
          end

          class_eval <<-EOV
            # prevents a user from submitting a crafted form that bypasses activation
            attr_protected :created_at, :updated_at
          EOV

          include ActiveRecord::Acts::MuckComment::InstanceMethods
          extend ActiveRecord::Acts::MuckComment::SingletonMethods
          
        end
      end

      # class methods
      module SingletonMethods

      end
      
      # All the methods available to a record that has had <tt>acts_as_muck_comment</tt> specified.
      module InstanceMethods
        
        # Send an email to everyone in the thread
        def after_create
          CommentMailer.deliver_new_comment(self) if GlobalConfig.send_email_for_new_comments
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
end
