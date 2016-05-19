module ResultsHelper
  def comment_icon(comment)
    "<i class=\"glyphicon glyphicon-envelope data-toggle=\"tooltip\" title=\"#{comment}\"></i>".html_safe
  end
end