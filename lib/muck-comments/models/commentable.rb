# include MuckComments::Models::MuckCommentable
module MuckComments
  module Models
    module MuckCommentable
      extend ActiveSupport::Concern
    
      included do
        has_many :comments, :as => :commentable, :dependent => :destroy
      end
      
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