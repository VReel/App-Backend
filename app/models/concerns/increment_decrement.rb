module IncrementDecrement
  extend ActiveSupport::Concern

  # rubocop:disable SkipsModelValidations
  def increment(model, field)
    model.with_lock do
      model.update_columns(field => model.send(field) + 1)
    end
  end

  def decrement(model, field)
    model.with_lock do
      model.update_columns(field => model.send(field) - 1)
    end
  end
  # rubocop:enable SkipsModelValidations
end
