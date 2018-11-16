class SupplementalClaimIntake < ClaimReviewIntake
  enum error_code: Intake::ERROR_CODES

  def find_or_build_initial_detail
    SupplementalClaim.new(veteran_file_number: veteran_file_number)
  end

  private

  def review_params
    request_params.permit(:receipt_date, :benefit_type, :legacy_opt_in_approved)
  end
end
