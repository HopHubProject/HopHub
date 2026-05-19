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
      row :number_of_confirmed_offers do |event|
        event.offers.confirmed.count
      end
      row :number_of_unconfirmed_offers do |event|
        event.offers.unconfirmed.count
      end
      row :number_of_confirmed_ride_requests do |event|
        event.ride_requests.confirmed.count
      end
      row :number_of_unconfirmed_ride_requests do |event|
        event.ride_requests.unconfirmed.count
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
      event.confirmed_offers.count
    end
    column :ride_requests do |event|
      event.ride_requests.count
    end
  end

  show do
    panel "Offers (way there) (#{event.offers.way_there.count})" do
      table_for event.offers.way_there do
        column :id do |offer|
          link_to offer.id, admin_offer_path(offer)
        end
        column :name
        column :seats
        column :date
        column :location
        column :country
        column :notes
        column :confirmed_at
      end
    end

    panel "Offers (way back) (#{event.offers.way_back.count})" do
      table_for event.offers.way_back do
        column :id do |offer|
          link_to offer.id, admin_offer_path(offer)
        end
        column :name
        column :seats
        column :date
        column :location
        column :country
        column :notes
        column :confirmed_at
      end
    end

    panel "Ride requests (way there) (#{event.ride_requests.way_there.count})" do
      table_for event.ride_requests.way_there do
        column :id do |rr|
          link_to rr.id, admin_ride_request_path(rr)
        end
        column :email
        column :location
        column :country
        column :radius
        column :end_date
        column :confirmed_at
      end
    end

    panel "Ride requests (way back) (#{event.ride_requests.way_back.count})" do
      table_for event.ride_requests.way_back do
        column :id do |rr|
          link_to rr.id, admin_ride_request_path(rr)
        end
        column :email
        column :location
        column :country
        column :radius
        column :end_date
        column :confirmed_at
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
