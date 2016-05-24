module ApplicationHelper
  def calendar_button
    '<span class="input-group-addon calendar-button">
      <span class="glyphicon glyphicon-calendar"></span>
    </span>'
  end

  def link_to_anchor_on_compare(anchor_id, results_ids)
    link_to compare_path(result: results_ids, anchor: anchor_id), {class: 'small link-unstyled anchor'} do
      '<i class="glyphicon glyphicon-link"></i>'.html_safe
    end
  end

  def link_to_anchor_on_report(anchor_id, id)
    link_to report_result_path(result: id, anchor: anchor_id), {class: 'small link-unstyled anchor'} do
      '<i class="glyphicon glyphicon-link"></i>'.html_safe
    end
  end

  def anchor(anchor_id)
    content_tag 'span', nil, {id: anchor_id, class: 'request-bookmark'}
  end
end
