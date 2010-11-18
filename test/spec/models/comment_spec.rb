require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  
  before do
    @user = Factory(:user)
    @comment = @user.comments.build(:body => 'a test comment')
    @comment.user = @user
    @comment.save!
  end
  
  it { should validate_presence_of :body }
  it { should belong_to :user }
  it { should belong_to :commentable }
  
  describe "sanitize" do
    before do
      @comment = Factory(:comment)
    end
    it "should sanitize user input fields" do
      @comment.should sanitize(:body)
    end
  end
  
  describe "scopes" do
    it { should scope_by_newest }
    it { should scope_by_oldest }
    it { should scope_newer_than }
    it "should scope by user" do
      Comment.by_user(@user).should include(@comment)
    end
  end
  
  it "should require body" do
    lambda {
      u = Factory.build(:comment, :body => nil)
      u.should_not be_valid
      u.errors[:body].should_not be_empty
    }.should_not change(Comment, :count)
  end
      
  it "should not have a parent if it is a root Comment" do
    @comment.parent.should be_nil
  end

  it "should be able to see how many child Comments it has" do
    @comment.children.size.should == 0
  end

  it "should be able to add child Comments" do
    # Set commentable to be the same for each comment or else you will get 'Impossible move, target node cannot be inside moved tree.' since the comments would be in a different scope.  (Comments are scoped to commentable)
    parent = Factory(:comment, :commentable => @user)
    child = Factory(:comment, :commentable => @user)
    child.move_to_child_of(parent)
    parent.children.size.should == 1
  end    

  describe "after having a child added" do
    before do
      # Set commentable to be the same for each comment or else you will get 'Impossible move, target node cannot be inside moved tree.' since the comments would be in a different scope.  (Comments are scoped to commentable)
      @child = Factory(:comment, :commentable => @user)
      @child.move_to_child_of(@comment)
    end
  
    it "should be able to be referenced by its child" do
      @comment.should == @child.parent
    end
  
    it "should be able to see its child" do
      @child.should == @comment.children.first
    end
  end
  
end