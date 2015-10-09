require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:ricardo)
    @non_admin = users(:elena)
  end

  test "index as admin with pagination and delete links" do
    log_in_as(@admin)

    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'

    first_page = User.paginate(page: 1)
    first_page.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user.admin?
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end
