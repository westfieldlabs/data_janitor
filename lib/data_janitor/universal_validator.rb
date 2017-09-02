module DataJanitor
  module UniversalValidator
    # TODO: Disabled until we decide to apply this condition as a standard validation
    # TODO: Run standard validators instead of home-brewed
    # validate :validate_field_values
    # ACCEPTABLE_BOOLEAN_VALUES = %w(t true y yes on 1 f false n no off 0) # this list was taken from Postgres spec. TRUE FALSE, that are also there, are not listed because they are DB-native literals and have no representation in Ruby code
    def validate_field_values(options)
      optional = options.split(':').map(&:strip)
      return if optional.include? 'no-type-check'

      # selected_attributes = self.changed? ? self.changed_attributes : self.attributes
      selected_attributes = self.attributes

      selected_attributes.each do |field_name, field_val|
        column = self.column_for_attribute field_name
        report_error = lambda { |msg| errors[column.name] << msg }

        if column.array
          next if optional.include? 'no-array'
          report_error.call "cannot be nil" if field_val.nil?
          next
        end

        case column.type
        when :boolean
          next if optional.include? 'no-boolean'
          report_error.call "cannot be nil" if field_val.nil?
          # report_error.call("must be a valid boolean") unless ACCEPTABLE_BOOLEAN_VALUES.include? field_val
        when :date
          # Date.iso8601(field_val) rescue report_error.call("must be a date in ISO-8601")
        when :time
          # Time.iso8601(field_val) rescue report_error.call("must be a datetime in ISO-8601")
        when :datetime
          # Time.iso8601(field_val) rescue report_error.call("must be a datetime in ISO-8601")
        when :decimal
          next if optional.include? 'no-decimal'
          report_error.call "cannot be nil" if field_val.nil?
          # TODO: run numericality test
        when :float
          next if optional.include? 'no-float'
          report_error.call "cannot be nil" if field_val.nil?
          # TODO: run numericality test
        when :integer
          next if optional.include? 'no-integer'
          report_error.call "cannot be nil" if field_val.nil?
          # TODO: run numericality test
        when :string, :text
          next if optional.include?('no-string') || optional.include?('no-text')
          if field_val.nil?
            # Almost never does an app need to distinguish between nil and empty string, yet nil needs special handling in all cases
            report_error.call "cannot be nil. Use an empty string instead if that's what you wanted."
          else
            # Our apps strings output text to the web where whitespace is meaningless
            report_error.call "cannot have leading/trailing whitespaces" if field_val =~ /\A\s/ || field_val =~ /\s\z/
            # TODO: Should we constrain to certain encoding types?
          end
        end
      end
    end
  end
end
