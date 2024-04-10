class ContentsController < ApplicationController
  private

  def method_missing(method, *args, &block)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})
    @content = markdown.render(Content.for(args.first, I18n.locale))
    render :show
  end

  def respond_to_missing?(method, include_private = false)
    true
  end
end