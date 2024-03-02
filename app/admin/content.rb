ActiveAdmin.register Content do
  permit_params :name, :content, :locale, :fallback

  index do
    selectable_column
    column :id do |content|
      link_to content.id, admin_content_path(content)
    end
    column :name
    column :locale
    column :fallback
    actions
  end
end
