ActiveAdmin.register Offer do
  permit_params :id, :offer_id, :email, :direction, :seats, :date, :location, :country, :notes, :confirmed_at, :token,
                offer_contacts_attributes: [:id, :kind, :value, :_destroy]

  scope :all, default: true
  scope :in_future
  scope :confirmed
  scope :unconfirmed
  scope :way_there
  scope :way_back

  member_action :confirm, method: :post do
    offer = Offer.find(params[:id])
    offer.update(confirmed_at: Time.now)
    offer.save(validate: false)
    redirect_to admin_offer_path(offer)
  end

  action_item :confirm, only: :show do
    if resource.confirmed_at.nil?
      link_to "Confirm", confirm_admin_offer_path(resource), method: :post, class: "action-item-button"
    end
  end

  member_action :unconfirm, method: :post do
    offer = Offer.find(params[:id])
    offer.update(confirmed_at: nil)
    offer.save(validate: false)
    redirect_to admin_offer_path(offer)
  end

  action_item :unconfirm, only: :show do
    unless resource.confirmed_at.nil?
      link_to "Unconfirm", unconfirm_admin_offer_path(resource), method: :post, class: "action-item-button"
    end
  end

  member_action :resend_confirmation, method: :post do
    offer = Offer.find(params[:id])
    OfferMailer.with(offer: offer).confirmed.deliver
    redirect_to admin_offer_path(offer)
  end

  action_item :resend_confirmation, only: :show do
    link_to "Resend confirmation", resend_confirmation_admin_offer_path(resource), method: :post, class: "action-item-button"
  end

  form do |f|
    f.inputs "Offer" do
      f.input :email
      f.input :direction, as: :select, collection: Offer::DIRECTIONS
      f.input :seats
      f.input :date
      f.input :location
      # Render as a plain text input: the default Formtastic :country input
      # requires the country_select plugin, which we don't use.
      f.input :country, as: :string
      f.input :notes
      f.input :confirmed_at
      f.input :token
    end

    f.inputs "Contacts" do
      f.has_many :offer_contacts, allow_destroy: true, new_record: true do |c|
        c.input :kind, as: :select, collection: OfferContact::KINDS
        c.input :value
      end
    end

    f.actions
  end

  index do
    selectable_column
    column :id do |offer|
      link_to offer.id, admin_offer_path(offer)
    end
    column :event do |offer|
      link_to offer.event.name, admin_event_path(offer.event)
    end
    column :name
    column :date
    column :location
    column :country
    column :transport
    column :seats
    column :direction
    column(:contacts) { |offer| offer.offer_contacts.size }
  end

  sidebar "Public links", only: :show do
    attributes_table_for offer do
      row :public_link do |offer|
        link_to event_offer_path(offer.event, offer), event_offer_path(offer.event, offer)
      end

      row :public_edit_link do |offer|
        link_to edit_event_offer_path(offer.event, offer), edit_event_offer_path(offer.event, offer, token: offer.token)
      end
    end
  end

  show do
    attributes_table do
      row :id
      row :event
      row :name
      row :email
      row :direction
      row :transport
      row :driver
      row :seats
      row :date
      row :location
      row :country
      row :latitude
      row :longitude
      row :notes
      row :confirmed_at
      row :token
      row :locale
      row :created_at
      row :updated_at
    end

    panel "Contacts" do
      table_for offer.offer_contacts do
        column :kind
        column :value
        column :link do |c|
          link_to c.value, c.link, target: '_blank', rel: 'noopener' if c.link.present?
        end
      end
    end
  end
end
