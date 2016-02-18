class CompareReport


  attr_reader :result1, :result2

  def initialize(request1, request2)
    @result1 = request1
    @result2 = request2
  end

  def description
    description = {}
    %w(version rps duration profile test_run_date).each do |key|
      values = {}
      values[:result1] = @result1.send(key)
      values[:result2] = @result2.send(key)
      description[key.gsub('_', ' ').capitalize] = values
    end
    description
  end

end