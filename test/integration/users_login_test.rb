require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:ricardo)
  end

  test "log in with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, session: { email: "", password: "" }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "log in with valid information then log out" do
    # Visit log in page
    get login_path

    # Send log in form
    post login_path, session: { email: @user.email, password: "password" }
    assert_redirected_to @user

    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    assert is_logged_in?

    # Click the log out link
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url

    # Simulate a second log out from a different browser
    delete logout_path

    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
end
