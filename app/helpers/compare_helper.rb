module CompareHelper
  def parameter_to_compare?(parameter)
    ['Rps', 'Duration', 'Profile', 'Data version', 'Time cutting percent', 'Value smoothing interval'].include? parameter
  end

  def link_to_result(result_id, prefix = nil)
    link_to "#{prefix}#{result_id}", result_path(result_id)
  end

  def link_to_anchor_on_compare(anchor_id, results_ids)
    link_to compare_path(result: results_ids, anchor: anchor_id), {class: 'small link-unstyled'} do
      '<i class="glyphicon glyphicon-link"></i>'.html_safe
    end
  end

  def link_to_anchor_on_report(anchor_id, id)
    link_to report_result_path(result: id, anchor: anchor_id), {class: 'small link-unstyled'} do
      '<i class="glyphicon glyphicon-link"></i>'.html_safe
    end
  end

  def anchor(anchor_id)
    content_tag 'span', nil, {id: anchor_id, class: 'request-bookmark'}
  end
end