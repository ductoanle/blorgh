class Post < ActiveRecord::Base
  scoped_to_account
  extend Multitenacy::ScopedTo
  has_many :comments
end
