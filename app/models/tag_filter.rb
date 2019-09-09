# frozen_string_literal: true

class TagFilter
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = Tag.order(id: :desc)

    params.each do |key, value|
      next if key.to_s == 'page'

      scope.merge!(scope_for(key, value)) if value.present?
    end

    scope
  end

  private

  def scope_for(key, value)
    case key.to_s
    when 'context'
      Tag.discoverable if value == 'directory'
    when 'name'
      Tag.matches_name(value)
    when 'order'
      Tag.order(max_score: :desc) if value == 'popular'
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
    else
      raise "Unknown filter: #{key}"
    end
  end
end
