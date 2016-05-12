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

end
