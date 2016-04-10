module ApplicationHelper
  def parameter_to_compare?(parameter)
    ['Rps', 'Duration', 'Profile', 'Time cutting percent'].include? parameter
  end
end
