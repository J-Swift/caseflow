# frozen_string_literal: true

# given:
#   decision_review_class  (HigherLevelReview, for instance)
#   veteran
#   receipt_date
#   benefit_type
#
# answers whether or not the provided ids:
#   rating_issue_id
#   decision_issue_id
#   rating_decision_issue_id
#
# reference a contestable issue (`valid?` method)
# and returns that contestable issue (`contestable_issue` method)

class Api::V3::DecisionReview::LookupContestableIssue
  def initialize(opts)
    @decision_review_class,
      @veteran,
      @receipt_date,
      @benefit_type = opts.values_at(
        :decision_review_class,
        :veteran,
        :receipt_date,
        :benefit_type
      )
    @rating_issue_id,
      @decision_issue_id,
      @rating_decision_issue_id = [
        :ratingIssueId,
        :decisionIssueId,
        :ratingDecisionIssueId
      ].map { |key| opts[key].to_s.strip }
  end

  def found?
    !!contestable_issue
  end

  def contestable_issue
    @contestable_issue ||= contestable_issues_for_veteran_and_form_type.find do |ci|
      matches_rating_issue_id?(ci) &&
        matches_decision_issue_id?(ci) &&
        matches_rating_decision_issue_id?(ci)
    end
  end

  def matches_rating_issue_id?(contestable_issue)
    contestable_issue&.rating_issue_reference_id.to_s.strip == @rating_issue_id
  end

  def matches_decision_issue_id?(contestable_issue)
    contestable_issue&.decision_issue&.id.to_s.strip == @decision_issue_id
  end

  def matches_rating_decision_issue_id?(contestable_issue)
    contestable_issue&.rating_decision_reference_id.to_s.strip == @rating_decision_issue_id
  end

  def contestable_issues_for_veteran_and_form_type
    @contestable_issues_for_veteran_and_form_type ||= contestable_issue_generator.contestable_issues
  end

  private

  def contestable_issue_generator
    @contestable_issue_generator ||= ContestableIssueGenerator.new(
      @decision_review_class.new(
        veteran_file_number: @veteran.file_number,
        receipt_date: @receipt_date,
        benefit_type: @benefit_type
      )
    )
  end
end
