require 'test_helper'

class UsersShowTest < ActionDispatch::IntegrationTest
  test "an active user can be shown" do
    user = users(:elena)
    user.update_attribute(:activated, true)

    get user_path(user)
    assert_template 'users/show'
  end

  test "an inactive user cannot be shown" do
    user = users(:elena)
    user.update_attribute(:activated, false)

    get user_path(user)
    assert_redirected_to root_url
  end
end
