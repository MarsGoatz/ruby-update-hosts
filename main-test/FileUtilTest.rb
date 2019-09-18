require 'minitest/autorun'
require_relative '../main/FileUtil'

class FileUtilTest < Minitest::Test
  def test_is_etc_host_file_false
    assert_equal(false, FileUtil.etc_host_file(File.open("resources/not_etc_host_file")))
  end

  def test_is_etc_host_file_true
    assert_equal(true, FileUtil.etc_host_file(File.open("resources/etc_host_file_first_entry_ipv_4")))
  end

  def test_is_etc_host_file_ipv6_true
    assert_equal(true, FileUtil.etc_host_file(File.open("resources/etc_host_file_first_entry_ipv_6")))
  end
end




