require 'minitest/autorun'
require '../main/BlockedUrlSetBuilder'
require 'set'

class BlockedUrlSetBuilderTest < Minitest::Test
  def test_build_blocked_url_set_local
    blocked_url_set_instance = BlockedUrlSetBuilder.new('../main-test/whitelisted_urls')
    blocked_url_set = blocked_url_set_instance.build_blocked_url_set(['../main-test/resources'])

    # assert_equal(3, blocked_url_set.length)

    %w[somedomain.com someotherdomain.com someotherotherdomain.com].each do |entry|
      assert_equal(true, blocked_url_set.member?(entry))
    end

    %w[somewhitelistedurl.com someotherwhitelistedurl.com].each do |entry|
      assert_equal(false, blocked_url_set.member?(entry))
    end
  end
end