ActiveAdmin.register Entry do
  permit_params :id, :entry_id, :email, :entry_type, :direction, :seats, :date, :location, :notes, :confirmed_at, :token

  member_action :unconfirm, method: :post do
    entry = Entry.find(params[:id])
    entry.update(confirmed_at: nil)
    redirect_to admin_entry_path(entry)
  end

  action_item :unconfirm, only: :show do
    link_to "Unconfirm", unconfirm_admin_entry_path(entry), method: :post
  end

  member_action :resend_confirmation, method: :post do
    entry = Entry.find(params[:id])
    EntryMailer.with(entry: entry).confirmed.deliver
    redirect_to admin_entry_path(entry)
  end

  action_item :resend_confirmation, only: :show do
    link_to "Resend confirmation", resend_confirmation_admin_entry_path(entry), method: :post
  end


  sidebar "Public links", only: :show do
    attributes_table_for entry do
      row :public_link do |entry|
        link_to event_entry_path(entry.event, entry), event_entry_path(entry.event, entry)
      end

      row :public_edit_link do |entry|
        link_to edit_event_entry_path(entry.event, entry), edit_event_entry_path(entry.event, entry, token: entry.token)
      end
    end
  end
end
