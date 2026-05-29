// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "@hotwired/stimulus"
import "@hotwired/stimulus-loading"
import "controllers"
import "popper"
import "bootstrap"

document.addEventListener("turbo:frame-missing", (event) => {
  const { detail: { response, visit } } = event;
  event.preventDefault();
  visit(response.url);
});

// Keep [data-scroll-reset] pages pinned to the top after a Turbo visit.
//
// The offer detail page is reached from a long offer listing. On Turbo
// "restore" visits (browser back/forward) Turbo re-applies the page's saved
// scroll position, and it does so *after* turbo:load via its own
// requestAnimationFrame. Worse, Turbo scrolls with scrollRoot.scrollTo(x, y),
// which honors Bootstrap's `scroll-behavior: smooth`, so the restore animates
// across several frames. A single reset just loses the ordering race.
//
// Instead, re-assert the top every frame for a short window using
// behavior:"instant" (order-independent, bypasses smooth scrolling). Bail out
// the moment the user actively scrolls so we never fight a deliberate scroll.
function pinToTop() {
  if (!document.querySelector("[data-scroll-reset]")) return;

  let active = true;
  const stop = () => {
    active = false;
    ["wheel", "touchstart", "keydown"].forEach((e) =>
      window.removeEventListener(e, stop)
    );
  };
  ["wheel", "touchstart", "keydown"].forEach((e) =>
    window.addEventListener(e, stop, { passive: true })
  );

  const deadline = performance.now() + 500;
  const tick = () => {
    if (!active) return;
    window.scrollTo({ top: 0, left: 0, behavior: "instant" });
    if (performance.now() < deadline) requestAnimationFrame(tick);
    else stop();
  };
  tick();
}
document.addEventListener("turbo:load", pinToTop);

// The offer detail page pins to the top (above). The "back to event" link,
// however, should return to the listing at the scroll position the user left —
// i.e. behave like the browser Back button, which triggers Turbo's scroll
// restoration, rather than a fresh advance visit that lands at the top.
//
// Record the destination whenever we leave the event listing; if the back link
// points at the offer we came from, pop history instead of navigating so Turbo
// restores the listing's scroll position.
document.addEventListener("turbo:before-visit", (event) => {
  if (document.querySelector("[data-event-listing]")) {
    sessionStorage.setItem("hhOfferFromListing", event.detail.url);
  }
});

document.addEventListener(
  "click",
  (event) => {
    const link = event.target.closest("[data-back-to-event]");
    if (!link) return;

    const from = sessionStorage.getItem("hhOfferFromListing");
    if (!from) return;

    const cameFromListing =
      new URL(from, window.location.origin).pathname === window.location.pathname;
    if (cameFromListing) {
      event.preventDefault();
      sessionStorage.removeItem("hhOfferFromListing");
      window.history.back();
    }
  },
  true
);
