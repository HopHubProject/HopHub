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
    params.slice(:locale, :direction, :admin_token).permit!
  end

  def title
    @title.join(" | ")
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
    case t.to_s
    when 'any'     then 'bi bi-asterisk'
    when 'car'     then 'bi bi-car-front'
    when 'train'   then 'bi bi-train-front'
    when 'bus'     then 'bi bi-bus-front'
    when 'bicycle' then 'bi bi-bicycle'
    when 'foot'    then 'bi bi-person-walking'
    else                'bi bi-star'
    end
  end

  def icon_class_for_contact_kind(kind)
    case kind.to_s
    when 'phone'     then 'bi bi-telephone'
    when 'sms'       then 'bi bi-chat-text'
    when 'signal'    then 'bi bi-signal'
    when 'whatsapp'  then 'bi bi-whatsapp'
    when 'telegram'  then 'bi bi-telegram'
    when 'instagram' then 'bi bi-instagram'
    else                  'bi bi-chat'
    end
  end

  def placeholder_for_contact_kind(kind)
    case kind.to_s
    when 'phone'     then '+491234567890'
    when 'sms'       then '+491234567890'
    when 'signal'    then 'yourname.42'
    when 'whatsapp'  then '+491234567890'
    when 'telegram'  then '@yourname'
    when 'instagram' then '@yourname'
    else                  ''
    end
  end
end
