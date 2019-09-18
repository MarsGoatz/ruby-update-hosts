require 'open-uri'
require 'set'
require_relative 'FileUtil'
require_relative 'ResourceManager'

# Class that will loop through folders and
# add entries to a set which are supposed to be
# blocked by the ETC host file
class BlockedUrlSetBuilder

  def initialize(whitelisted_entries_file_path, resource_manager)
    @resource_manager = resource_manager
    @whitelisted_entries_path = whitelisted_entries_file_path
    @whitelisted_set = whitelisted_entries
    @blocked_url_set = Set.new
    @duplicates_set = Set.new
  end

  def build_blocked_url_set(folder_path_array)
    folder_path_array.each do |folder_path|
      absolute_folder_path = FileUtil.get_absolute_file_path(folder_path)
      Dir.foreach(absolute_folder_path) do |file|
        unless File.directory? file
          file_to_read = File.open(absolute_folder_path + '/' + file)
          add_entries_to_set(file_to_read)
        end
      end
    end
    @blocked_url_set
  end

  def duplicate_set
    @duplicates_set
  end

  private

  def add_entries_to_set(file)
    filename = File.basename(file.path).to_s
     "testing filename #{filename}"
    if !(filename.start_with? 'remote') && FileUtil.etc_host_file(file)
      populate_from_etc_host_format(file)
    elsif File.basename(file.path).start_with? 'remote'
      add_entries_from_remote_urls(file)
    else
      puts 'throw exception'
    end
  end

  def add_entries_from_remote_urls(file)
    file.each do |line|
      puts 'looping through remote list'
      url = URI.encode(line.strip)
      puts "remote url is #{url.to_s}"
      file = open(URI.parse(url))
      populate_from_etc_host_format(file)
    end
  end

  def populate_from_etc_host_format(file)
    file.each do |line|
      next if line.start_with?('#')

      line = line.split(/\s+/)
      line.each do |item|
        line.delete(item) if item.empty?
      end

      url_to_block = line[1].to_s.strip
      populate_url_to_blocked_url_set(url_to_block)
    end
  end

  def populate_blocked_ur_set(file)
    file.each do |line|
      populate_url_to_blocked_url_set(line.to_s.strip)
    end
  end

  def populate_url_to_blocked_url_set(url_to_block)
    if !@whitelisted_set.member?(url_to_block) &&
       !@blocked_url_set.member?(url_to_block) &&
       !url_to_block.empty?

      @blocked_url_set.add(url_to_block)
    end
    if !@whitelisted_set.member?(url_to_block) &&
       @blocked_url_set.member?(url_to_block) &&
       !url_to_block.empty?

      @duplicates_set.add(url_to_block)
    end

  end

  def whitelisted_entries
    whitelist_set = Set.new
    whitelisted_entries = @resource_manager.resource(@whitelisted_entries_path)

    whitelisted_entries.each do |whitelist_entry|
      whitelist_set.add(whitelist_entry.to_s.strip)
      puts "whitelist entry is #{whitelist_entry.to_s.strip}"
    end
    whitelist_set
  end

  def clean_up_line_entry(line)
    line = line.split(/\s+/)
    line.each do |item|
      line.delete(item) if item.empty?
    end
    line
  end
end

# resource_manager = ResourceManager.new('macosx', 'random')
#
# path_array = %w(resources/app/adult_content_filter/)
# blocked_set = BlockedUrlSetBuilder.new('whitelisted_entries', resource_manager)
# set = blocked_set.build_blocked_url_set(path_array)
# line = 1
# set.each do |entry|
#   puts " #{line} with entry #{entry}"
#   line += 1
# end
# duplicate_set = blocked_set.duplicate_set
# line = 0
# duplicate_set.each do |entry|
#   puts " #{line } with duplicate entry #{entry}"
#   line += 1
# end
