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
        column :entries do |event|
          event.entries.count
        end
      end
    end

    panel "Recent Entries" do
      table_for Entry.confirmed.order("created_at asc").limit(5) do
        column :id do |entry|
          link_to entry.id, admin_entry_path(entry)
        end
        column :event do |entry|
          link_to entry.event.name, admin_event_path(entry.event)
        end
        column :name
        column :seats
        column :date
        column :location
        column :direction
      end
    end

    div do
      panel "Currently active" do
        para "Events: #{Event.confirmed.count}"
        para "Entries: #{Entry.confirmed.count}"
      end
    end
  end
end
