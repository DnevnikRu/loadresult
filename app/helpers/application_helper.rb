module ApplicationHelper
  def parameter_to_compare?(parameter)
    ['Rps', 'Duration', 'Profile', 'Time cutting percent', 'Value smoothing interval'].include? parameter
  end

  def comment_icon(comment)
    "<i class=\"glyphicon glyphicon-envelope data-toggle=\"tooltip\" title=\"#{comment}\"></i>".html_safe
  end
end
