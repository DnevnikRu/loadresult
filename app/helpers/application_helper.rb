module ApplicationHelper
  def parameter_to_compare?(parameter)
    ['Rps', 'Duration', 'Profile', 'Time cutting percent', 'Value smoothing interval'].include? parameter
  end
end
