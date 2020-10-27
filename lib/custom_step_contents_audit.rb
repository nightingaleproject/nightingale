class CustomStepContentsAudit < Audited::Audit
  before_save :diff_death_record_contents

  def diff_death_record_contents
    if self.auditable_type == 'DeathRecord' && self.audited_changes.include?("contents")
      # Only want to modify the stored diff if its not the first time.
      if self.audited_changes['contents'].is_a?(Array) && self.audited_changes['contents'].length > 1
        self.audited_changes['contents'] = Hashdiff.best_diff(self.audited_changes['contents'][0], self.audited_changes['contents'][1])
      elsif self.audited_changes['contents'].is_a?(Hash)
        self.audited_changes['contents'] = Hashdiff.best_diff({}, self.audited_changes['contents'])
      end
    end
  end
end
