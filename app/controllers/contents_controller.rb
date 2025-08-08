class ContentsController < ApplicationController
  private

  def method_missing(method, *args, &block)
    renderer = Redcarpet::Render::HTML.new(no_styles: true, hard_wrap: true, filter_html: true)
    markdown = Redcarpet::Markdown.new(renderer, autolink: true, tables: true)
    c = Content.for(args.first, I18n.locale)

    unless c.nil?
      rendered = markdown.render(c.content)
      @content = ActionController::Base.helpers.sanitize(rendered)
      @title.push c.title
    else
      @content = ""
    end

    render :show
  end

  def respond_to_missing?(method, include_private = false)
    true
  end
end
