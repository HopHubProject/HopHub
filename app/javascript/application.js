// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "@hotwired/stimulus"
import "@hotwired/stimulus-loading"
import "controllers"
import "popper"
import "bootstrap"
import "tempus-dominus";
import "altcha"
import "confetti"
import "maptiler"

document.addEventListener("turbo:frame-missing", (event) => {
  console.log("turbo:frame-missing", event)
  const { detail: { response, visit } } = event;
  event.preventDefault();
  visit(response.url);
});
