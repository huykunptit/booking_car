package vehicle.booking.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@Slf4j
@Service
public class ViettelAiService {

    private static final String TOKEN = "93f3886be392ad743f665ac2200b40b7";
    private static final String BASE_URL = "https://viettelai.vn/ekyc";
    private final RestTemplate restTemplate = new RestTemplate();

    @SuppressWarnings("unchecked")
    public Map<String, Object> ocrIdCard(MultipartFile file) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);

            MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
            body.add("image", new ByteArrayResource(file.getBytes()) {
                @Override public String getFilename() { return file.getOriginalFilename(); }
            });

            HttpEntity<MultiValueMap<String, Object>> request = new HttpEntity<>(body, headers);
            String url = BASE_URL + "/id_card?token=" + TOKEN;
            ResponseEntity<Map> response = restTemplate.postForEntity(url, request, Map.class);
            return response.getBody() != null ? response.getBody() : Map.of("code", 500);
        } catch (IOException e) {
            log.error("ViettelAI ocrIdCard error", e);
            return Map.of("code", 500, "en_message", e.getMessage());
        }
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> spoofCheck(MultipartFile file) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);

            MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
            body.add("file", new ByteArrayResource(file.getBytes()) {
                @Override public String getFilename() { return file.getOriginalFilename(); }
            });

            HttpEntity<MultiValueMap<String, Object>> request = new HttpEntity<>(body, headers);
            String url = BASE_URL + "/id_spoof_check?token=" + TOKEN;
            ResponseEntity<Map> response = restTemplate.postForEntity(url, request, Map.class);
            return response.getBody() != null ? response.getBody() : Map.of("code", 500);
        } catch (IOException e) {
            log.error("ViettelAI spoofCheck error", e);
            return Map.of("code", 500, "en_message", e.getMessage());
        }
    }
}
