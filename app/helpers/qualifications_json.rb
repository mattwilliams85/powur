module QualificationsJson
  class QualificationViewDecorator < SimpleDelegator
    attr_reader :list, :item

    def initialize(view, list, item)
      super(view)
      @list, @item = list, item
    end

    def list_init(partial_path)
      klass :qualifications, :list

      json.entities @list, partial: partial_path, as: :qualification
    end

    def item_init(rel_value)
      klass :qualificattion

      entity_rel(rel_value)
    end

    def properties(qualification = @item)
      json.properties do
        json.type qualification.type_string
        json.call(qualification, :id, :type_display,
                  :path, :time_period, :quantity, :product_id)
        if qualification.is_a?(GroupSalesQualification)
          json.max_leg_percent qualification.max_leg_percent
        end
        json.product qualification.product.name
      end
    end
  end

  def qual_json
    @qual_json ||= QualificationViewDecorator
      .new(self, @qualifications, @qualification)
  end
end
