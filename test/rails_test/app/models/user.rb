class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
  end
  acts_as_muck_user
  has_muck_profile
  has_many :comments
  include MuckComments::Models::Commentable
end