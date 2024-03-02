import "maptilersdk";
import "maptilersdk-maptiler-geocoder";

class FilterControl {
  constructor(direction) {
    this._callbacks = {};
    this._direction = direction;
  }

  on(event, callback) {
    this._callbacks[event] = callback;
  }

  onAdd(map) {
    const mapElement = document.getElementById('map');
    const way_there = mapElement.dataset.waythere;
    const way_back = mapElement.dataset.wayback;

    const options = {
      way_there: way_there,
      way_back: way_back,
    };

    const optionsHTML = Object.keys(options).map((key) => {
      const selected = key === this._direction ? 'selected' : '';
      return `<option value="${key}" ${selected}>${options[key]}</option>`;
    });

    this._map = map;
    this._container = document.createElement('div');
    this._container.className = 'maplibregl-ctrl';
    this._container.innerHTML = `
      <select id="direction" class="form-select">
        ${optionsHTML}
      </select>
      `;

    this._container.onchange = (e) => {
      const v = e.target.value
      this._callbacks['directionChange'] && this._callbacks['directionChange'](v);
    };

    return this._container;
  }

  onRemove() {
    this._container.parentNode.removeChild(this._container);
    this._map = undefined;
  }
}

function entriesMap(way_there_url, way_back_url, direction) {
  const opts = {
    container: 'map',
    style: maptilersdk.MapStyle.STREETS,
    geolocate: maptilersdk.GeolocationType.COUNTRY,
  };

  const map = new maptilersdk.Map(opts);
  const url = direction === 'way_there' ? way_there_url : way_back_url;

  map.on('load', () => {
    map.addSource('entries', {
      type: 'geojson',
      data: url,
      cluster: true,
      clusterMaxZoom: 13,
      clusterRadius: 50,
    });

    map.addLayer({
      id: 'clusters',
      type: 'circle',
      source: 'entries',
      filter: ['has', 'point_count'],
      paint: {
        'circle-color': [
          'step',
          ['get', 'point_count'],
          '#51bbd6',
          10,
          '#f1f075',
          30,
          '#f28cb1',
        ],
        'circle-radius': [
          'step',
          ['get', 'point_count'],
          20,
          10,
          30,
          20,
          40,
        ],
      },
    });

    map.addLayer({
      id: 'cluster-count',
      type: 'symbol',
      source: 'entries',
      filter: ['has', 'point_count'],
      layout: {
        'text-field': '{point_count_abbreviated}',
        'text-font': ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
        'text-size': 12
      }
    });

    // inspect a cluster on click
    map.on('click', 'clusters', function (e) {
      var features = map.queryRenderedFeatures(e.point, {
        layers: ['clusters']
      });
      var clusterId = features[0].properties.cluster_id;
      map.getSource('entries').getClusterExpansionZoom(
        clusterId,
        function (err, zoom) {
          if (err) return;

          map.easeTo({
            center: features[0].geometry.coordinates,
            zoom: zoom
          });
        }
      );
    });

    function fitMapToClusterBounds(map, sourceId, clusterLayerId) {
      const clusters = map.queryRenderedFeatures({ layers: [clusterLayerId] });
      const clusterLeavesPromises = clusters.map(cluster => {
        return new Promise((resolve, reject) => {
          const clusterId = cluster.properties.cluster_id;
          map.getSource(sourceId).getClusterLeaves(clusterId, cluster.properties.point_count, 0, (error, leaves) => {
            if (error) {
              reject(error);
            } else {
              resolve(leaves);
            }
          });
        });
      });

      Promise.all(clusterLeavesPromises).then(clusterLeavesArrays => {
        const allLeaves = clusterLeavesArrays.flat();
        if (allLeaves.length > 0) {
          const bounds = allLeaves.reduce((acc, leaf) => {
            return acc.extend(leaf.geometry.coordinates);
          }, new maptilersdk.LngLatBounds(allLeaves[0].geometry.coordinates, allLeaves[0].geometry.coordinates));

          map.fitBounds(bounds, { padding: 20 });
        }
      }).catch(error => console.error('Error retrieving cluster leaves:', error));
    }

    let adjusted = false;
    let entriesLoaded = false;

    map.on('data', function(e) {
      if (e.sourceId === 'entries' && map.isSourceLoaded('entries')) {
        entriesLoaded = true;
        addMarkersForVisiblePoints();
      }
    });

    map.on('render', function() {
      if (adjusted || !entriesLoaded || map.isMoving() || !map.areTilesLoaded())
        return;

      fitMapToClusterBounds(map, 'entries', 'clusters');
      adjusted = true;
    });

    let currentMarkers = [];
    let currentPopups = [];

    function addMarkersForVisiblePoints() {
      // First, remove existing markers to avoid duplicates
      currentMarkers.forEach(marker => marker.remove());
      currentMarkers = [];

      // Remove existing popups
      currentPopups.forEach(popup => popup.remove());
      currentPopups = [];

      const features = map.querySourceFeatures('entries', {
        sourceLayer: 'entries',
        filter: ['!', ['has', 'point_count']]
      });

      features.forEach(feature => {
        const coords = feature.geometry.coordinates;
        const popup = new maptilersdk.Popup().setHTML(feature.properties.name);
        const marker =  new maptilersdk.Marker()
            .setLngLat(coords)
            .setPopup(popup)
            .addTo(map);

        popup.setHTML('<div class="spinner-border" role="status"><span class="visually-hidden">Loading...</span></div>');

        popup.on('open', () => {
          fetch(feature.properties.url)
            .then(response => {
              if (!response.ok)
                throw new Error('Unable to fetch popup content');

              return response.text();
            })
            .then(data => {
              popup.setHTML(data);
            })
        });

        currentMarkers.push(marker);
      });
    }

    map.on('zoom', addMarkersForVisiblePoints);

    // Initial check in case the map starts at a high zoom level
    addMarkersForVisiblePoints();

    const fc = new FilterControl(direction);
    fc.on('directionChange', (direction) => {
      const url = direction === 'way_there' ? way_there_url : way_back_url;
      map.getSource('entries').setData(url);
      addMarkersForVisiblePoints();
    });
    map.addControl(fc, 'top-left');
  });

  return map;
}

function singleMap() {
  let longitude_field = document.getElementById('entry_longitude');
  let latitude_field = document.getElementById('entry_latitude');
  let location_field = document.getElementById('entry_location');

  if (!longitude_field || !latitude_field || !location_field)
    return;

  let longitude = undefined;
  let latitude = undefined;

  let opts = {
    container: 'map',
    style: maptilersdk.MapStyle.STREETS,
  };

  if (longitude_field && latitude_field) {
    longitude = longitude_field.value;
    latitude = latitude_field.value;

    if (longitude && latitude) {
      opts.center = [longitude, latitude];
      opts.zoom = 13;
    } else {
      opts.geolocate = maptilersdk.GeolocationType.COUNTRY;
    }
  }

  const map = new maptilersdk.Map(opts);

  var marker = new maptilersdk.Marker({
    draggable: true
  });

  if (longitude !== undefined && latitude !== undefined)
    marker.setLngLat([longitude, latitude]).addTo(map);

  async function move_marker(lng, lat) {
    const results = await maptilersdk.geocoding.reverse([lng, lat]);

    longitude_field.value = lng;
    latitude_field.value = lat;

    marker.setLngLat([lng, lat]).addTo(map);

    if (results.features.length > 0) {
      location_field.value = results.features[0].place_name;
    }
  }

  marker.on('dragend', () => {
    const lngLat = marker.getLngLat();
    move_marker(lngLat.lng, lngLat.lat);
  });

  map.on('click', async (e) => {
    const {lng, lat} = e.lngLat;
    move_marker(lng, lat);
  });

  return map;
}

function load_map() {
  const mapElement = document.getElementById('map');

  if (!mapElement)
    return;

  maptilersdk.config.apiKey = mapElement.dataset.apikey;

  let map;

  if (mapElement.dataset.direction) {
    map = entriesMap(mapElement.dataset.waythereurl,
                     mapElement.dataset.waybackurl,
                     mapElement.dataset.direction);
  } else {
    map = singleMap();
  }

  const gc = new maptilersdkMaptilerGeocoder.GeocodingControl({});
  map.addControl(gc, 'top-left');
}

document.addEventListener('turbo:load', load_map);
document.addEventListener('turbo:frame-load', load_map);

