module TrendHelper
  def request_color_trend(base, value)
    base = base.to_i
    if value > base
      '#D80F0A'
    elsif value < -base
      '#15A918'
    else
      '#333'
    end
  end

  def result_ids_to_links(result_ids)
    result_ids.map { |id| link_to(id, result_path(id)) }.join(', ').html_safe
  end
end
