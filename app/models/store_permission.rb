include HexHelper

class StorePermission < ActiveRecord::Base
  attr_accessible :store_id, :user_id, :permission_level, :admin_hex

  validates :store_id, numericality: true, presence: true
  validates :user_id, numericality: true, allow_blank: true
  validates :permission_level, numericality: true, presence: true

  belongs_to :user
  belongs_to :store

  after_create :alert_user
  before_destroy :send_pink_slip

  PERMISSION_TYPES = { 1 => "ADMIN", 2 => "STOCKER" }

  def self.create_from_params_and_user(params, user)
    store_permission = StorePermission.new(params)
    store_permission.user = user
    store_permission.save!
  end

  def self.invite_user_to_access_store(store_permission_params, email)
    permission = StorePermission.new(store_permission_params)
    permission.admin_hex = create_hex
    permission.save
    permission.send_invite_email(email)
  end

  def send_invite_email(email)
    if permission_level == 1
      UserMailer.invite_admin_email(store_id, admin_hex, email).deliver
    elsif permission_level == 2
      UserMailer.invite_stocker_email(store_id, admin_hex, email).deliver
    end
  end

  def send_pink_slip
    if permission_level == 1
      UserMailer.fire_admin(store_id, user.email_address).deliver
    elsif permission_level == 2
      UserMailer.fire_stocker(store_id, user.email_address).deliver
    end
  end

  private

  def alert_user
    if user_id && user_id != store.creating_user_id
      email = User.find(user_id).email_address
      if permission_level == 1
        UserMailer.alert_admin_email(store_id, email).deliver
      elsif permission_level == 2
        UserMailer.alert_stocker_email(store_id, email).deliver
      end
    end
  end
end

# == Schema Information
#
# Table name: store_permissions
#
#  id               :integer         not null, primary key
#  user_id          :integer
#  store_id         :integer
#  permission_level :integer
#  admin_hex        :string(255)
#

