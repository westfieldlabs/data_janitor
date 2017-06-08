module DataJanitor
  module AuditValidatable
    # extended data janitor model validations that apply
    # to new records and data_janitor audit purposes
    def dj_validations(&block)
      with_options(on: [:dj_audit, :create], &block)
    end

    # extended data janitor model validations that apply
    # data_janitor audit purposes
    def dj_audit_validations(&block)
      with_options(on: [:dj_audit], &block)
    end
  end
end
