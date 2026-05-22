package de.heizinventur.backend.system;

import static org.assertj.core.api.Assertions.assertThat;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
class SystemStatusIntegrationTest {

  @Container
  static final PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:17-alpine")
      .withDatabaseName("heizinventur")
      .withUsername("heizinventur")
      .withPassword("heizinventur");

  @DynamicPropertySource
  static void registerProperties(DynamicPropertyRegistry registry) {
    registry.add("spring.datasource.url", postgres::getJdbcUrl);
    registry.add("spring.datasource.username", postgres::getUsername);
    registry.add("spring.datasource.password", postgres::getPassword);
    registry.add("spring.datasource.driver-class-name", postgres::getDriverClassName);
    registry.add("spring.mail.host", () -> "127.0.0.1");
    registry.add("spring.mail.port", () -> 1025);
  }

  @Autowired
  JdbcTemplate jdbcTemplate;

  @Autowired
  TestRestTemplate restTemplate;

  @Autowired
  ObjectMapper objectMapper;

  @LocalServerPort
  int port;

  @Test
  void appliesBaselineMigration() {
    Long rows = jdbcTemplate.queryForObject("select count(*) from app_installation", Long.class);

    assertThat(rows).isEqualTo(1L);
  }

  @Test
  void exposesApplicationAndDatabaseStatus() throws Exception {
    ResponseEntity<String> response = restTemplate.getForEntity("/api/system/status", String.class);

    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);

    JsonNode body = objectMapper.readTree(response.getBody());
    assertThat(body.path("application").asText()).isEqualTo("UP");
    assertThat(body.path("database").asText()).isEqualTo("UP");
  }
}
