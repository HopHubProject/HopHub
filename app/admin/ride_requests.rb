ActiveAdmin.register RideRequest do
  permit_params :id, :event_id, :email, :direction, :location, :country, :latitude, :longitude, :radius, :end_date, :confirmed_at, :token, :locale

  scope :all, default: true
  scope :confirmed
  scope :unconfirmed
  scope :way_there
  scope :way_back

  member_action :confirm, method: :post do
    ride_request = RideRequest.find(params[:id])
    ride_request.update(confirmed_at: Time.now)
    ride_request.save(validate: false)
    redirect_to admin_ride_request_path(ride_request)
  end

  action_item :confirm, only: :show do
    if resource.confirmed_at.nil?
      link_to "Confirm", confirm_admin_ride_request_path(resource), method: :post, class: "action-item-button"
    end
  end

  member_action :unconfirm, method: :post do
    ride_request = RideRequest.find(params[:id])
    ride_request.update(confirmed_at: nil)
    ride_request.save(validate: false)
    redirect_to admin_ride_request_path(ride_request)
  end

  action_item :unconfirm, only: :show do
    unless resource.confirmed_at.nil?
      link_to "Unconfirm", unconfirm_admin_ride_request_path(resource), method: :post, class: "action-item-button"
    end
  end

  member_action :resend_confirmation, method: :post do
    ride_request = RideRequest.find(params[:id])
    RideRequestMailer.with(ride_request: ride_request).created.deliver
    redirect_to admin_ride_request_path(ride_request)
  end

  action_item :resend_confirmation, only: :show do
    link_to "Resend confirmation", resend_confirmation_admin_ride_request_path(resource), method: :post, class: "action-item-button"
  end

  index do
    selectable_column
    column :id do |rr|
      link_to rr.id, admin_ride_request_path(rr)
    end
    column :event do |rr|
      link_to rr.event.name, admin_event_path(rr.event)
    end
    column :email
    column :direction
    column :location
    column :country
    column :radius
    column :end_date
    column :confirmed_at
    column :created_at
  end

  sidebar "Public links", only: :show do
    attributes_table_for ride_request do
      row :event_link do |rr|
        link_to event_path(rr.event), event_path(rr.event)
      end

      row :public_destroy_link do |rr|
        link_to event_ride_request_destroy_path(rr.event, rr),
                event_ride_request_destroy_path(rr.event, rr, token: rr.token)
      end
    end
  end

  form do |f|
    f.inputs "Ride Request Details" do
      f.input :event_id
      f.input :email
      f.input :direction, as: :select, collection: RideRequest::DIRECTIONS
      f.input :location
      f.input :country
      f.input :latitude
      f.input :longitude
      f.input :radius, as: :select, collection: RideRequest::RADIUSES
      f.input :end_date
      f.input :locale
      f.input :confirmed_at
    end
    f.actions
  end
end
