# frozen_string_literal: true

class TagFilter
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = Tag.order(max_score: :desc)

    params.each do |key, value|
      scope.merge!(scope_for(key, value)) if value.present?
    end

    scope
  end

  private

  def scope_for(key, value)
    case key.to_s
    when 'context'
      Tag.discoverable if value == 'directory'
    when 'review'
      case value.to_s
      when 'reviewed'
        Tag.reviewed.order(reviewed_at: :desc)
      when 'unreviewed'
        Tag.unreviewed
      when 'pending_review'
        Tag.pending_review.order(requested_review_at: :desc)
      else
        raise "Unknown filter: #{key}#{value}"
      end
    when 'name'
      Tag.search_for(value)
    else
      raise "Unknown filter: #{key}"
    end
  end
end
