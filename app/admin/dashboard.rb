# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    panel "Recent Events" do
      table_for Event.confirmed.order("created_at asc").limit(5) do
        column :id do |event|
          link_to event.id, admin_event_path(event)
        end
        column :name
        column :description
        column :end_date
        column :offers do |event|
          event.offers.count
        end
        column :ride_requests do |event|
          event.ride_requests.count
        end
      end
    end

    panel "Recent Offers" do
      table_for Offer.confirmed.order("created_at asc").limit(5) do
        column :id do |offer|
          link_to offer.id, admin_offer_path(offer)
        end
        column :event do |offer|
          link_to offer.event.name, admin_event_path(offer.event)
        end
        column :name
        column :seats
        column :date
        column :location
        column :direction
      end
    end

    panel "Recent Ride Requests" do
      table_for RideRequest.confirmed.order("created_at desc").limit(5) do
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
      end
    end

    div do
      panel "Currently active" do
        para "Events: #{Event.confirmed.count}"
        para "Offers: #{Offer.confirmed.count}"
        para "Ride requests: #{RideRequest.confirmed.count}"
      end
    end
  end
end
