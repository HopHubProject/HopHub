class HomeController < ApplicationController
  def index
    single_event_id = ENV['HOPHUB_SINGLE_EVENT_ID']
    if single_event_id.present?
      redirect_to event_path(single_event_id)
      return
    end

    content = Content.for('instance-info', I18n.locale)
    unless content.nil?
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})
      @instance_info_text = markdown.render(content.content)
      @instance_info_title = content.title
    end
  end
end
