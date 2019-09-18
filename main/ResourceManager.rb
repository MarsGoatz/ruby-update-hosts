#check OS specific folder
#check app folder

class ResourceManager
  def initialize(os, version)
    @os = os
    @version = version
  end

  def resource(resource)
    if resource.to_s.start_with? 'path'
      path_resource resource
    else
          file_resource resource
    end
  end

  private

  def file_resource(resource)
    resource_path = resource_path(@os, resource)
    return File.open(resource_path) if File.exists?(resource_path)

    resource_path = resource_path('app', resource)
    File.open(resource_path) if File.exists? resource_path
  end

  def path_resource(resource)
    resource_path = resource_path(@os, resource)
    file = File.open(resource_path)

    file&.each do |path|
      return path
    end

    resource_path = resource_path('app', resource)
    file = File.open(resource_path)
    file&.each do |path|
      return path
    end
  end

  def resource_path(folder, resource)
    File.expand_path("resources/#{folder}/#{resource}", __dir__)
  end
end