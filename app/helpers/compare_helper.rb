module CompareHelper
  def parameter_to_compare?(parameter)
    ['Rps', 'Duration', 'Profile', 'Data version', 'Time cutting percent', 'Value smoothing interval'].include? parameter
  end

  def link_to_result(result_id, prefix = nil)
    link_to "#{prefix}#{result_id}", result_path(result_id)
  end

  def link_to_anchor(compare_report, anchor_id)
    link_to compare_path(result: [compare_report.result1.id, compare_report.result2.id], anchor: anchor_id), {class: 'small link-unstyled'} do
      '<i class="glyphicon glyphicon-link"></i>'.html_safe
    end
  end

  def anchor(anchor_id)
    content_tag 'span', nil, {id: anchor_id, class: 'request-bookmark'}
  end
end