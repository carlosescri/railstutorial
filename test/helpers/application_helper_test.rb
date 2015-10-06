require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  def setup
    @base_title = "Ruby On Rails Tutorial Sample App"
  end

  test "full_title helper" do
    assert_equal full_title, @base_title
    assert_equal full_title("Help"), "Help | #{@base_title}"
  end
end
