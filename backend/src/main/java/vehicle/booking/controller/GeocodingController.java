package vehicle.booking.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.util.Collections;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/geo")
@RequiredArgsConstructor
@Slf4j
public class GeocodingController {

    @Value("${mapbox.access-token}")
    private String accessToken;

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    private static final String MAPBOX = "https://api.mapbox.com/geocoding/v5/mapbox.places";

    private Object fetch(String url) throws Exception {
        var resp = restTemplate.exchange(URI.create(url), HttpMethod.GET, HttpEntity.EMPTY, String.class);
        return objectMapper.readValue(resp.getBody(), Object.class);
    }

    /**
     * Search by text → [{place_name, lat, lon, id}]
     * Mapbox GeoJSON → flattened to a simple list for the Flutter client.
     */
    @GetMapping("/search")
    public ResponseEntity<Object> search(
            @RequestParam String text,
            @RequestParam(defaultValue = "10") int limit) {
        String encoded;
        try {
            encoded = java.net.URLEncoder.encode(text, "UTF-8");
        } catch (Exception e) {
            encoded = text;
        }
        String url = UriComponentsBuilder
                .fromHttpUrl(MAPBOX + "/" + encoded + ".json")
                .queryParam("access_token", accessToken)
                .queryParam("language", "vi")
                .queryParam("country", "vn")
                .queryParam("limit", limit)
                .queryParam("types", "poi,address,place,district,locality,neighborhood,postcode")
                .toUriString();
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> geojson = (Map<String, Object>) fetch(url);
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> features = (List<Map<String, Object>>) geojson.getOrDefault("features", Collections.emptyList());

            List<Map<String, Object>> results = features.stream().map(f -> {
                @SuppressWarnings("unchecked")
                List<Double> center = (List<Double>) f.getOrDefault("center", List.of(0.0, 0.0));
                return Map.<String, Object>of(
                        "place_name", f.getOrDefault("place_name", ""),
                        "lon", center.size() > 0 ? center.get(0) : 0.0,
                        "lat", center.size() > 1 ? center.get(1) : 0.0,
                        "id", f.getOrDefault("id", "")
                );
            }).toList();

            return ResponseEntity.ok(results);
        } catch (Exception e) {
            log.warn("Mapbox search failed: {}", e.getMessage());
            return ResponseEntity.ok(Collections.emptyList());
        }
    }

    /**
     * Reverse geocode lat/lng → {place_name}
     */
    @GetMapping("/reverse")
    public ResponseEntity<Object> reverse(
            @RequestParam double lat,
            @RequestParam double lng) {
        String url = UriComponentsBuilder
                .fromHttpUrl(MAPBOX + "/" + lng + "," + lat + ".json")
                .queryParam("access_token", accessToken)
                .queryParam("language", "vi")
                .queryParam("limit", 1)
                .toUriString();
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> geojson = (Map<String, Object>) fetch(url);
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> features = (List<Map<String, Object>>) geojson.getOrDefault("features", Collections.emptyList());
            String placeName = features.isEmpty() ? lat + ", " + lng
                    : (String) features.get(0).getOrDefault("place_name", lat + ", " + lng);
            return ResponseEntity.ok(Map.of("display_name", placeName));
        } catch (Exception e) {
            log.warn("Mapbox reverse failed: {}", e.getMessage());
            return ResponseEntity.ok(Collections.emptyMap());
        }
    }
}
