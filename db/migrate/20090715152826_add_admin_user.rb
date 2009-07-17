class AddAdminUser < ActiveRecord::Migration
  def self.up
    @user = User.new
    @user.login = 'admin'
    @user.email = 'admin@example.com'
    @user.salt = 'NiCl2'
    @user.password = @user.password_confirmation = 'admin'
    @user.save!
  end

  def self.down
    @user.find_by_login('admin').delete
  end
end
