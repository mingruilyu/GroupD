require 'test_helper'

class UserTest < ActiveSupport::TestCase

	test "should create user" do
		user = User.new(
			email:							'tom@gmail.com',
			password:						'12345678',
      cellphone_id:       3,
      city_id:            1
		)
		assert_difference 'User.count' do
			user.save	
		end
	end

	test "should not create user because email or password not present" do
		user = User.new
		assert !user.save
		assert user.errors[:email].any?
		assert user.errors[:password].any?
	end

	test "should not create user because password too short" do
		user = User.new(
      username:           'tom',
			email:							'tom@gmail.com',
      cellphone_id:       1,
			password:						'123456',
			city_id:						1
		)
		assert !user.save
		assert user.errors[:password].any?
		assert_equal user.errors[:password].join(" ;"),
								 "is too short (minimum is 8 characters)"
	end

	test "should not create user because email not unique" do 
		user = User.new(
      username:           'tom',
			email: 		          users(:one).email,
      cellphone_id:       1,
			password:	          '12345678',
			city_id:	          1
    )
		assert !user.save
		assert user.errors[:email].any?
		assert_equal user.errors[:email].join(" ;"),
								"has already been taken"
	end
end
