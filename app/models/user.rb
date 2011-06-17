class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

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
end
