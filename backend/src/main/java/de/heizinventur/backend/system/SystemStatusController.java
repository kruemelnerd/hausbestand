package de.heizinventur.backend.system;

import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/system")
class SystemStatusController {

  private final JdbcTemplate jdbcTemplate;

  SystemStatusController(JdbcTemplate jdbcTemplate) {
    this.jdbcTemplate = jdbcTemplate;
  }

  @GetMapping("/status")
  SystemStatusResponse status() {
    return new SystemStatusResponse("UP", databaseStatus());
  }

  private String databaseStatus() {
    try {
      jdbcTemplate.queryForObject("select 1", Integer.class);
      return "UP";
    } catch (DataAccessException ex) {
      return "DOWN";
    }
  }
}
