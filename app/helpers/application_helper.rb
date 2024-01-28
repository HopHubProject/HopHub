module ApplicationHelper
  def bootstrap_class_for flash_type
    {
      success: "alert-primary",
      error: "alert-danger",
      recaptcha_error: "alert-danger",
      alert: "alert-warning",
      notice: "alert-info"
    }[flash_type.to_sym] || flash_type.to_s
  end

  def url_params
    params.permit(:locale, :direction, :entry_type, :admin_token)
  end

  def accept_tos_text
    t('accept_terms',
      tos: link_to(t('tos'), tos_path),
      privacy_policy: link_to(t('privacy_policy'), privacy_path)
    ).html_safe
  end

  def icon_class_for_entry_type(t)
    case t.to_sym
    when :offer
      'bi bi-gift'
    when :request
      'bi bi-search'
    else
      raise "Unknown entry type: #{t}"
    end
  end

  def icon_class_for_transport(t)
    case t.to_sym
    when :car
      'bi bi-car-front'
    when :train
      'bi bi-train-front'
    when :bus
      'bi bi-bus-front'
    when :bicycle
      'bi bi-bicycle'
    when :foot
      'bi bi-person-walking'
    else
      'bi bi-star'
    end
  end
end
