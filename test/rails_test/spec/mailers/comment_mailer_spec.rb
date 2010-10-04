require File.dirname(__FILE__) + '/../spec_helper'

describe CommentMailer do

  describe "deliver emails" do

    def setup
      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.deliveries = []
      @expected = TMail::Mail.new
      @expected.set_content_type "text", "plain", { "charset" => 'utf-8' }
    end
    
    it "should send new comment email" do
      comment = Factory(:comment)
      email = CommentMailer.new_comment(comment).deliver
      ActionMailer::Base.deliveries.should_not be_empty
      email.to.should == [user.email]
      email.from.should == [MuckEngine.configuration.from_email]
    end
    
  end  
end
