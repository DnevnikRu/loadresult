module CompareHelper
  def parameter_to_compare?(parameter)
    ['Rps', 'Duration', 'Profile', 'Data version', 'Time cutting percent', 'Value smoothing interval'].include? parameter
  end

  def link_to_result(result_id, prefix = nil)
    link_to "#{prefix}#{result_id}", result_path(result_id)
  end
end