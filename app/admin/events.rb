ActiveAdmin.register Event do
  permit_params :id, :name, :description, :end_date, :default_country, :admin_email, :admin_token, :shadow_banned, :confirmed_at

  scope :all, default: true
  scope :confirmed
  scope :unconfirmed

  member_action :confirm, method: :post do
    event = Event.find(params[:id])
    event.update(confirmed_at: Time.now)
    redirect_to admin_event_path(event)
  end

  action_item :confirm, only: :show do
    if resource.confirmed_at.nil?
      link_to "Confirm", confirm_admin_event_path(resource), method: :post, class: "action-item-button"
    end
  end

  member_action :unconfirm, method: :post do
    event = Event.find(params[:id])
    event.update(confirmed_at: nil)
    redirect_to admin_event_path(event)
  end

  action_item :unconfirm, only: :show do
    unless resource.confirmed_at.nil?
      link_to "Unconfirm", unconfirm_admin_event_path(resource), method: :post, class: "action-item-button"
    end
  end

  member_action :resend_confirmation, method: :post do
    event = Event.find(params[:id])
    EventMailer.with(event: event).created.deliver
    redirect_to admin_event_path(event)
  end

  action_item :resend_confirmation, only: :show do
    link_to "Resend confirmation", resend_confirmation_admin_event_path(resource), method: :post, class: "action-item-button"
  end

  sidebar "Details", only: :show do
    attributes_table_for event do
      row :id
      row :name
      row :description
      row :end_date
      row :default_country
      row :admin_email
      row :admin_token
      row :shadow_banned
      row :created_at
      row :updated_at
      row :confirmed_at
      row :seats_added_total
      row :current_entries do |event|
        event.entries.count
      end
    end
  end

  sidebar "Public links", only: :show do
    attributes_table_for event do
      row :public_link do |event|
        link_to event_path(event), event_path(event)
      end

      row :public_edit_link do |event|
        link_to edit_event_path(event), edit_event_path(event, admin_token: event.admin_token)
      end
    end
  end

  index do
    selectable_column
    column :id do |event|
      link_to event.id, admin_event_path(event)
    end
    column :name
    column :description
    column :end_date do |event|
      event.end_date.to_date
    end
    column :created_at
    column :confirmed_at
    column :offers do |event|
      event.offers.count
    end
  end

  show do
    panel "Offers (way there)" do
      table_for event.offers_way_there do
        column :id do |entry|
          link_to entry.id, admin_entry_path(entry)
        end
        column :name
        column :seats
        column :date
        column :location
        column :notes
      end
    end

    panel "Offers (way back)" do
      table_for event.offers_way_back do
        column :id do |entry|
          link_to entry.id, admin_entry_path(entry)
        end
        column :name
        column :seats
        column :date
        column :location
        column :notes
      end
    end
  end

  form do |f|
    f.inputs "Event Details" do
      f.input :id
      f.input :name
      f.input :description
      f.input :end_date
      f.input :admin_email
      f.input :shadow_banned
      f.input :confirmed_at
    end
    f.actions
  end
end
