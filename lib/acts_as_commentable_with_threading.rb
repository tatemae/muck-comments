# ActsAsCommentableWithThreading
module Acts #:nodoc:
  module CommentableWithThreading #:nodoc:

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_commentable
        has_many :comments, :as => :commentable, :dependent => :destroy
        include Acts::CommentableWithThreading::InstanceMethods
        extend Acts::CommentableWithThreading::SingletonMethods
      end
    end
    
    # This module contains class methods
    module SingletonMethods
      
    end
    
    # This module contains instance methods
    module InstanceMethods
      
      # Helper method to display only root threads, no children/replies
      def root_comments
        self.comments.find(:all, :conditions => {:parent_id => nil})
      end
      
      # Helper method that defaults the submitted time.
      def add_comment(comment)
        self.comments << comment
      end
      
      # Determines whether or not the give user can comment on the parent object
      def can_comment?(user)
        return true unless user.blank?
        false
      end
      
    end
    
  end
end

ActiveRecord::Base.send(:include, Acts::CommentableWithThreading)