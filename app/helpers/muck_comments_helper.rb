module MuckCommentsHelper
  
  def show_comments(comments)
    render :partial => 'comments/comment', :collection => comments
  end
  
  # parent is the object to which the comments will be attached
  # comment is the optional parent comment for the new comment.
  def comment_form(parent, comment = nil, render_new = false, comment_button_class = 'comment-submit')
    render :partial => 'comments/form', :locals => {:parent => parent, 
                                                    :comment => comment, 
                                                    :render_new => render_new,
                                                    :comment_button_class => comment_button_class}
  end

  # make_muck_parent_params is defined in muck-engine and used by many of the engines.
  # This will generate a url suitable for a form to post a create to.
  def new_comment_path_with_parent(parent)
    comments_path(make_muck_parent_params(parent))
  end
  
  # Generates a link to the 'new' page for a comment
  def new_comment_for_path(parent)
    new_comment_path(make_muck_parent_params(parent))
  end
  
  # Renders a delete button for a comment
  def delete_comment(comment, button_type = :button, button_text = t("muck.activities.delete"))
    render :partial => 'shared/delete', :locals => { :delete_object => comment, 
                                                         :button_type => button_type,
                                                         :button_text => button_text, 
                                                         :form_class => 'comment-delete',
                                                         :delete_path => comment_path(comment, :format => 'js') }
  end
  
  # outputs a partial that will embed disqus into any page with a unique url
  #  
  # Extra instructions from the disqus site:
  # Append #disqus_thread to the end of permalinks. The comment count code will replace the text of these links with the comment count.
  # For example, you may have a link with this HTML:
  # <a href="http://example.com/my_article.html#disqus_thread">Comments</a>
  # The comment count code will replace the text "Comments" with the number of comments on the page http://example.com/my_article.html
  #
  # disqus_short_name: The short name you selected when setting up your site.
  def disqus(disqus_short_name)
    render :partial => 'external/disqus', :locals => { :disqus_short_name => disqus_short_name }
  end
  
end