// Import and register all your controllers from the importmap under controllers/*

import { application } from "controllers/application"

// Lazy-load controllers as they appear in the DOM. Each controller module is
// fetched on demand the first time an element with its data-controller mounts,
// which also defers any libraries the controller imports (tempus-dominus,
// altcha, canvas-confetti, geonames). Pages that don't use a controller never
// download its code. Requires preload: false on the controller pins in
// config/importmap.rb so modulepreload links aren't emitted on every page.
import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
lazyLoadControllersFrom("controllers", application)
