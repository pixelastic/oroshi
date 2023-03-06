# Arguments-related methods
module ArgumentsHelper
  # Check if the input is an image
  def image?(input)
    methods = [:jpg?, :gif?, :png?]
    methods.each do |method|
      return true if send(method, input)
    end
    false
  end

  # Check that all the input exists and are of the current type
  def validate_inputs(inputs, ext)
    # Convert any extension to an array of symbols
    ext = ext.split(',') if ext.is_a? String
    ext = [ext] unless ext.is_a? Array
    ext = ext.map(&:to_sym)

    # Using full path
    inputs = inputs.map do |input|
      File.expand_path(input)
    end

    # Keeping only if exists and match the valid types
    inputs = inputs.select do |input|
      next false unless File.exist?(input)

      should_keep = false
      ext.each do |extension|
        should_keep = true if send("#{extension}?", input)
      end

      should_keep
    end

    inputs
  end
end
