require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup should not success" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: {name: "", email: "user@invalid", password: "foo",
                              password_confirmation: "bar"}
    end
    assert_template 'users/new'
    assert_select '#error_explanation'
    assert_select '.field_with_errors #user_name'
    assert_select '.field_with_errors #user_email'
    assert_select '.field_with_errors #user_password'
    assert_select '.field_with_errors #user_password_confirmation'
  end

  test "valid signup data should success" do
    get signup_path
    assert_difference 'User.count', 1 do
      post_via_redirect users_path, user: {name: "Example User",
                                           email: "user@example.com",
                                           password: "foobar",
                                           password_confirmation: "foobar"}
    end
    assert_template 'users/show'
    assert_not flash.empty?
    assert_select '.alert-success'
  end
end
