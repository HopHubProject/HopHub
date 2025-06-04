export function resolveZipCode(s, elements, config) {
  // Remove existing dropdown if it exists
  const existingDropdown = document.getElementById('zip-dropdown');
  if (existingDropdown) {
    existingDropdown.remove();
  }

  elements.latitudeInput.value = '';
  elements.longitudeInput.value = '';

  if (s.length > 3) {
    const countryCode = elements.countryInput.value;
    const url = `${config.url}&postal_code=${encodeURIComponent(s)}&country_code=${encodeURIComponent(countryCode)}`;

    console.log('Fetching zip lookup for:', s, 'with country code:', countryCode);

    fetch(url)
      .then(response => response.json())
      .then(postalCodes => {
        if (!postalCodes || postalCodes.length === 0) {
          return;
        }

        const dropdown = document.createElement('ul');
        dropdown.id = 'zip-dropdown';
        dropdown.className = 'dropdown-menu show';

        postalCodes.forEach(result => {
          const li = document.createElement('li');
          const a = document.createElement('a');
          a.className = 'dropdown-item';
          a.innerHTML = '<b>' + result.postalCode + '</b> ' + result.placeName;
          a.addEventListener('click', (event) => {
            event.preventDefault();
            const v = result.postalCode + ' ' + result.placeName;
            elements.locationInput.value = v;
            elements.latitudeInput.value = result.lat;
            elements.longitudeInput.value = result.lng;
            dropdown.remove();

            console.log('Selected zip code: ' + v + ' (' + result.lat + ', ' + result.lng + ')');
          });

          li.appendChild(a);
          dropdown.appendChild(li);
        });

        // Insert dropdown immediately after the location input element
        elements.locationInput.parentElement?.insertBefore(dropdown, elements.locationInput.nextSibling);
      })
      .catch(error => {
        console.error('Error fetching zip lookup:', error);
      });
  }
}

window.resolveZipCode = resolveZipCode;
