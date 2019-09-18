class FileUtil
  def self.etc_host_file(file)
    file.each do |line|
      next if line.start_with?('#')

      line = clean_up_string(line)
      first_entry = line[0].to_s.strip
      next if first_entry.empty?

      return ip_v_4_addr(first_entry) || ip_v_6_addr(first_entry)
    end
  end

  def self.get_absolute_file_path(relative_path)
    File.expand_path(relative_path, __dir__)
  end

  private

  def self.clean_up_string(line)
    line = line.split(/\s+/)
    line.each do |item|
      line.delete(item) if item.empty?
    end
    line
  end

  def self.ip_v_4_addr(str)
    str.match('(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}') ? true : false
  end

  def self.ip_v_6_addr(str)
    if str.match('^[0-9a-fA-F]{1,4}(:[0-9a-fA-F]{1,4}){7}$') ||
        str.match('::1') ||
        str.match('fe80::1%lo0')
      true
    else
      false
    end
  end
end