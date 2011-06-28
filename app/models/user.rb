class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  #has_many :lastfm_users, :dependent => :destroy

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :lastfm_username

  # Default state is a user with only read access.
  # Admin state is a user with read and write access.
  state_machine :state, :initial => :default do
    state :default
    state :admin

    event :adminify do
      transition :default => :admin
    end

    event :deadminify do
      transition :admin => :default
    end
  end  

  # Override devise method so the user can update his information without
  # entering his current password.
  def update_with_password(params={})
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    result = update_attributes(params)
    clean_up_passwords
    result
  end

  # True if the user is currently synced with lastfm, false otherwise.
  def synced_with_lastfm?
    lastfm_username.present?
  end
end
