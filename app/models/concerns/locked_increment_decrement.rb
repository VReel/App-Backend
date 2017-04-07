module LockedIncrementDecrement
  extend ActiveSupport::Concern

  # rubocop:disable SkipsModelValidations
  def locked_increment(field)
    with_lock do
      update_columns(field => send(field) + 1)
    end
  end

  def locked_decrement(field)
    with_lock do
      update_columns(field => send(field) - 1)
    end
  end
  # rubocop:enable SkipsModelValidations
end
