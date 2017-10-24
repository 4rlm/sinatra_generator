class User < ActiveRecord::Base
  validates :username, :email, :pw_hash, presence: true
  validates :email, uniqueness: true

  # include BCrypt

  def password
    @password ||= BCrypt::Password.new(self.pw_hash)
    # @password ||= Password.new(pw_hash)
  end

  def password=(new_password)
    @password = BCrypt::Password.create(new_password)
    self.pw_hash = @password
  end

  # def self.authenticate(email, password)
  def self.authenticate(email, submitted_password)
    user = User.find_by_email(email)
    if user && user.password == submitted_password
      return user
    else
      return nil
    end
  end

end
