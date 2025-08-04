module ApplicationHelper
  def bootstrap_class_for flash_type
    {
      success: "alert-success",
      error: "alert-danger",
      recaptcha_error: "alert-danger",
      alert: "alert-warning",
      notice: "alert-info"
    }[flash_type.to_sym] || flash_type.to_s
  end

  def url_params
    params.permit(:locale, :direction, :admin_token)
  end

  def meta_description
    if @meta_description
      @meta_description
    else
      t('meta.description.default')
    end
  end

  def terms_and_conditions_prompt
    t('terms_and_conditions.prompt',
      tos: link_to(t('tos'), tos_path),
      privacy_policy: link_to(t('privacy_policy'), privacy_path)
    ).html_safe
  end

  def terms_and_conditions_accepted
    t('terms_and_conditions.accepted',
      tos: link_to(t('tos'), tos_path),
      privacy_policy: link_to(t('privacy_policy'), privacy_path)
    ).html_safe
  end

  def icon_class_for_transport(t)
    case t.to_sym
    when :any
      'bi bi-asterisk'
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
