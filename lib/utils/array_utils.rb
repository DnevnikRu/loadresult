module ArrayUtils
  def join_with_quotes(arr)
    %('#{arr.join("', '")}')
  end
end
