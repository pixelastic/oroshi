require_relative './command_helper'

# Arguments-related methods
module GitArgumentHelper
  include CommandHelper

  # Checks if the specified input looks like a filepath
  # Note: This is a best effort guess as anything could be a filepath
  def path?(input)
    return true unless (%r{^\./} =~ input).nil?

    false
  end

  # Checks if the specified input looks like a repo url
  def url?(input)
    # Example: git@github.com:pixelastic/vit.git
    regexp = /^(.*)@(.*):(.*)\.git$/
    !(regexp =~ input).nil?
  end

  # Check if the specific input looks like a shorthand username/reponame url
  def github_short_url?(input)
    # Example: username/reponame
    regexp = %r{^(.*)/(.*)$}
    !(regexp =~ input).nil?
  end

  # Checks if the specified input looks like a command line argument
  def argument?(input)
    !(input =~ /^--?/).nil?
  end

  def guess_elements(*inputs)
    # Allow for one array or splats
    inputs = inputs[0] if inputs.length == 1

    types = %w[remote tag branch url path]
    elements = {
      unknown: [],
      arguments: []
    }

    # Guessing each type
    inputs.each do |element|
      found_type = nil

      types.each do |type|
        # Already found the remote/tag/branch
        next if elements.key?(type.to_sym)

        # Is of this type, we remember it and break out of the loop
        if send("#{type}?", element)
          found_type = type
          break
        end
      end

      if found_type.nil?
        elements[:unknown] << element
      else
        elements[found_type.to_sym] = element
      end
    end

    # Setting default values
    types.each do |type|
      type_sym = type.to_sym
      current_type_method = "current_#{type}"

      # Already set
      next if elements.key?(type_sym)

      # Setting default if such a default is even possible
      if respond_to?(current_type_method)
        elements[type_sym] = send(current_type_method)
      end
    end

    # Finding arguments in "unknown" elements
    final_unknown = []
    elements[:unknown].each do |unknown|
      if argument?(unknown)
        elements[:arguments] << unknown
      else
        final_unknown << unknown
      end
    end
    elements[:unknown] = final_unknown

    elements
  end
end
