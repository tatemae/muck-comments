class Comment < ActiveRecord::Base
  include MuckComments::Models::MuckComment
end