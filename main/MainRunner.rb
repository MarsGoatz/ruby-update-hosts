require_relative 'EtcHostFileGenerator'
require_relative 'OsUtil'
require 'logger'

@debug_flag = false

ARGV.each do|a|
  puts "Argument: #{a}"
  if a.to_s.eql? 'debug'
    @debug_flag = true
  end
end

log = Logger.new('../build/log.txt')
log.level = Logger::DEBUG if @debug_flag
log.level = Logger::WARN unless @debug_flag
log.debug "This will be ignored"
log.error "This will not be ignored"

PERSONAL_FILTER_FOLDER_PATH = 'resources/app/personal_filter/'.freeze
ADULT_CONTENT_FOLDER_PATH = 'resources/app/adult_content_filter/'.freeze
ADS_FILTER_FOLDER_PATH = 'resources/app/ads_filter/'.freeze
MALWARE_FILTER_FOLDER_PATH = 'resources/app/malware_filter/'.freeze

WHITELISTED_ENTRIES_FILE = 'whitelisted_entries'.freeze
ETC_HOST_DEFAULT_FILE = 'etc_host_default'.freeze
ETC_HOST_TEMP_FILE = 'etc_host_temp'.freeze
ETC_HOSTS = 'hosts'.freeze
ETC_HOST_FILE_PATH = 'path_hosts_folder'.freeze

folder_array = [ADS_FILTER_FOLDER_PATH,
                ADULT_CONTENT_FOLDER_PATH,
                PERSONAL_FILTER_FOLDER_PATH,
                MALWARE_FILTER_FOLDER_PATH]

os = OsUtil.os
puts "the current os is #{os}"
resource_manager = ResourceManager.new(os.to_s, 'random')
blocked_url_set_builder = BlockedUrlSetBuilder.new(WHITELISTED_ENTRIES_FILE, resource_manager)
etc_hosts_generator = EtcHostFileGenerator.new(blocked_url_set_builder, resource_manager)
etc_hosts_generator.generate_etc_host_file folder_array
etc_hosts_generator.replace_old_hosts_file_with_new_entries(ETC_HOST_FILE_PATH, ETC_HOST_TEMP_FILE)

