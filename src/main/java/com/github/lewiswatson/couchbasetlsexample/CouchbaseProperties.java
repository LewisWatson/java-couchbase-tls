package com.github.lewiswatson.couchbasetlsexample;

import java.util.List;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;
import org.springframework.validation.annotation.Validated;

@Component
@ConfigurationProperties(prefix = "couchbase")
@Data
@Validated
public class CouchbaseProperties {

  /**
   * The list of hostnames (or IP addresses) to bootstrap from.
   */
  private List<String> bootstrapHosts;
  private TlsKeystore tlsKeystore;
  private Bucket bucket;

  /**
   * Defines the location/password of the Keystore file that contains the certificates with which to connect
   * to Couchbase securely.
   */
  @Data
  public static class TlsKeystore {
    private String location;
    private String password;
  }

  @Data
  public static class Bucket {
    /**
     * The name of the bucket to connect to.
     */
    private String name;
  }

}
