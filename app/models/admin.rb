class Admin < ActiveRecord::Base
  #devise :database_authenticatable, :trackable, :timeoutable, :lockable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
  #devise :validatable
end