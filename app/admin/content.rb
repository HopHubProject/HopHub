ActiveAdmin.register Content do
  permit_params :name, :content, :locale, :fallback
end
