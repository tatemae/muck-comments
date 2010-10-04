require 'muck_comments'
require 'rails'

module MuckComments
  class Engine < ::Rails::Engine
    
    def muck_name
      'muck-comments'
    end
    
    initializer 'muck_comments.helpers' do
      ActiveSupport.on_load(:action_view) do
        include MuckCommentsHelper
      end
    end
    
  end
end