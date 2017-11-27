class ResultFilter

  attr_reader :resources, :options

  DEFAULT_LIMIT = 10

  def initialize(resources, options)
    @resources = resources
    @options   = options
  end

  def filter
    if options[:project]
      project_id = Project.find_by(project_name: options[:project]).try(:id)
      if project_id
        @resources = resources.where(project_id: project_id)
      end
    end

    if options[:rps]
      @resources = resources.where(rps: options[:rps])
    end

    if options[:profile]
      @resources = resources.where(profile: options[:profile])
    end

    if options[:version]
      @resources = resources.where(version: options[:version])
    end

    if options[:duration]
      @resources = resources.where(duration: options[:duration])
    end

    if options[:sort_by] == 'version'
      @resources = Result.sort_by_version(resources)
    end

    @resources = resources.limit(options[:limit] ? options[:limit].to_i : DEFAULT_LIMIT)

    resources
  end
end