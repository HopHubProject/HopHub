ActiveAdmin.register Event do
  permit_params :id, :name, :description, :end_date, :admin_email, :admin_token, :shadow_banned, :confirmed_at

  member_action :unconfirm, method: :post do
    event = Event.find(params[:id])
    event.update(confirmed_at: nil)
    redirect_to admin_event_path(event)
  end

  action_item :unconfirm, only: :show do
    link_to "Unconfirm", unconfirm_admin_event_path(event), method: :post
  end

  member_action :resend_confirmation, method: :post do
    event = Event.find(params[:id])
    EventMailer.with(event: event).created.deliver
    redirect_to admin_event_path(event)
  end

  action_item :resend_confirmation, only: :show do
    link_to "Resend confirmation", resend_confirmation_admin_event_path(event), method: :post
  end

  sidebar "Details", only: :show do
    attributes_table_for event do
      row :id
      row :name
      row :description
      row :end_date
      row :admin_email
      row :admin_token
      row :shadow_banned
      row :created_at
      row :updated_at
      row :confirmed_at
      row :entries do |event|
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

    panel "Requests (way there)" do
      table_for event.requests_way_there do
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

    panel "Requests (way back)" do
      table_for event.requests_way_back do
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
end
