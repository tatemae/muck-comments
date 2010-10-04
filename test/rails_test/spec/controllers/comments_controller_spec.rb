require File.dirname(__FILE__) + '/../spec_helper'

describe Muck::CommentsController do

  before do
    @user = Factory(:user)
  end
  
  describe "GET new" do
    before do
      get :new, make_parent_params(@user)
    end
    it { should_not set_the_flash }
    it { should respond_with :success }
    it { should render_template :new }
  end

  describe "GET index using comment" do
    before do
      @comment = Factory(:comment, :commentable => @user)
      child = Factory(:comment, :commentable => @user)
      child.move_to_child_of(@comment)
      get :index, :format => 'html', :id => @comment.id
    end
    it { should_not set_the_flash }
    it { should respond_with :success }
    it { should render_template :index }
  end
    
  describe "GET index using parent" do
    before do
      # create a few comments to be displayed
      comment = Factory(:comment, :commentable => @user)
      child = Factory(:comment, :commentable => @user)
      child.move_to_child_of(comment)
      get :index, make_parent_params(@user).merge(:format => 'html')
    end
    it { should_not set_the_flash }
    it { should respond_with :success }
    it { should render_template :index }
  end

  describe "logged in" do
    before do
      activate_authlogic
      login_as @user
      @comment = Factory(:comment, :user => @user)
    end
    describe "delete comment" do
      it "shoulddelete comment" do
        lambda {
          delete :destroy, { :id => @comment.to_param, :format => 'json' }          
          @response.body.should include(I18n.t('muck.comments.comment_removed'))          
        }.should change(Comment, :count).by(-1)
      end
    end
  end
  
  describe "create comment" do
    it "should be able to create a comment" do
      lambda {
        post :create,  make_parent_params(@user).merge(:format => 'json', :comment => { :body => 'test' })          
      }.should change(Comment, :count)
    end
  end
  
end