require File.dirname(__FILE__) + '/../spec_helper'

describe User do

  describe "A class that is commentable" do
    before do
      @user = Factory(:user)
      @comment = @user.comments.build(:body => 'a test comment')
      @comment.user = @user
      @comment.save!
    end
    
    it "should have comments" do
      @user.comments.length.should == 1
    end
    it "should have comment cache" do
      @user.reload
      @user.comment_count.should == 1
    end
  end

end