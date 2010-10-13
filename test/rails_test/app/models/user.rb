class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
  end
  include MuckUsers::Models::MuckUser
  include MuckProfiles::Models::MuckUser
  has_many :comments
  include MuckComments::Models::MuckCommentable
end