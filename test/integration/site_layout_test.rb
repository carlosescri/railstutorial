require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:ricardo)
    @non_admin = users(:elena)
  end

  test "layout links for non-logged in users" do
    get root_path
    assert_template 'static_pages/home'

    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path

    assert_select "a[href=?]", users_path, count: 0
    assert_select "a[href=?]", user_path(@non_admin), count: 0
    assert_select "a[href=?]", edit_user_path(@non_admin), count: 0
    assert_select "a[href=?]", logout_path, count: 0

    get signup_path
    assert_select "title", full_title("Sign up")
  end

  test "layout links for logged in users" do
    log_in_as(@non_admin)

    get root_path
    assert_template 'static_pages/home'

    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path

    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", user_path(@non_admin)
    assert_select "a[href=?]", edit_user_path(@non_admin)
    assert_select "a[href=?]", logout_path

    get signup_path
    assert_select "title", full_title("Sign up")
  end
end
