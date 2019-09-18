require 'set'
require_relative 'BlockedUrlSetBuilder'
require 'fileutils'

class EtcHostFileGenerator

  def initialize(blocked_ur_set_builder, resource_manager)
    @blocked_url_set_builder = blocked_ur_set_builder
    @resource_manager = resource_manager
  end

  def generate_etc_host_file(blocked_url_folder_array)
    hosts_file = setup_hosts_template
    blocked_url_set = @blocked_url_set_builder
                      .build_blocked_url_set(blocked_url_folder_array)
    blocked_url_set.each do |entry|
      hosts_file << ETC_HOST_ENTRY_BLOCKED_URL_PREFIX + '    ' + entry + "\n"
    end
    hosts_file.close
  end

  def replace_old_hosts_file_with_new_entries(os_hosts_path, app_hosts_temp)
    os_hosts_path = @resource_manager.resource(os_hosts_path)
    File.delete(os_hosts_path + 'etc_host_temp') if File.exist? os_hosts_path + 'etc_host_temp'
    FileUtils.cp(@resource_manager.resource(app_hosts_temp), os_hosts_path)
    File.delete(os_hosts_path + 'hosts') if File.exist?(os_hosts_path + 'hosts')
    File.rename(os_hosts_path + 'etc_host_temp', os_hosts_path + 'hosts')
  end

  private

  ETC_HOST_ENTRY_BLOCKED_URL_PREFIX = '0.0.0.0'.freeze

  def setup_hosts_template
    default_hosts_file =
      File.open(@resource_manager.resource(ETC_HOST_DEFAULT_FILE))

    if File.exist?(@resource_manager.resource(ETC_HOST_TEMP_FILE))
      File.delete(@resource_manager.resource(ETC_HOST_TEMP_FILE))
    end
    hosts_template_file =
      File.new(File.expand_path('resources/app/' + ETC_HOST_TEMP_FILE, __dir__),
               'a')

    default_hosts_file.each do |line|
      hosts_template_file << line
    end
    hosts_template_file
  end
end