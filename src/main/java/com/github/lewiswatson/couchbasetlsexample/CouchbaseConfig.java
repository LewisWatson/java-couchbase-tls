package com.github.lewiswatson.couchbasetlsexample;

import com.couchbase.client.core.env.CertificateAuthenticator;
import com.couchbase.client.core.env.SecurityConfig;
import com.couchbase.client.core.env.TimeoutConfig;
import com.couchbase.client.java.Bucket;
import com.couchbase.client.java.Cluster;
import com.couchbase.client.java.ClusterOptions;
import com.couchbase.client.java.env.ClusterEnvironment;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Optional;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@Slf4j
public class CouchbaseConfig {

  @Bean(destroyMethod = "shutdown")
  public ClusterEnvironment clusterEnvironment(CouchbaseProperties properties) {
    Path tlsKeyStorePath = Paths.get(properties.getTlsKeystore().getLocation());
    log.info("Enabling TLS for all client/server couchbase communication using TLS Keystore: {}",
        tlsKeyStorePath);
    return ClusterEnvironment.builder()
        .securityConfig(SecurityConfig
            .enableTls(true)
            .trustStore(
                tlsKeyStorePath,
                properties.getTlsKeystore().getPassword(),
                Optional.empty()
            )
        )
        .build();
  }

  @Bean(destroyMethod = "disconnect")
  public Cluster cluster(CouchbaseProperties properties, ClusterEnvironment clusterEnvironment) {

    // List of cluster nodes, separated by commas
    String connectionString = properties.getBootstrapHosts().stream().collect(Collectors.joining(","));
    log.info("Connecting to couchbase cluster using connection string: {}", connectionString);

    Path tlsKeyStorePath = Paths.get(properties.getTlsKeystore().getLocation());
    log.info("Authenticating couchbase connecting using certificate from TLS keystore: {}",
        tlsKeyStorePath);

    ClusterOptions clusterOptions = ClusterOptions
        .clusterOptions(CertificateAuthenticator.fromKeyStore(
            tlsKeyStorePath,
            properties.getTlsKeystore().getPassword(),
            Optional.empty()))
        .environment(clusterEnvironment);

    return Cluster.connect(connectionString, clusterOptions);
  }

  /**
   * From the managing connections section of the Couchbase Java SDK 3.2 docs
   *
   * If you are connecting to a version of Couchbase Server older than 6.5, it will be more
   * efficient if the addresses are those of data (KV) nodes. You will in any case, with 7.0 and
   * earlier, need to open a `Bucket instance before connecting to any other HTTP services
   * (such as Query or Search.[)]
   *
   * Since we are currently targeting a couchbase 6.6+ server then we need to open a bucket, despite
   * not using it (at time of writing this comment)
   *
   * @link https://docs.couchbase.com/java-sdk/3.2/howtos/managing-connections.html
   */
  @Bean()
  public Bucket bucket(CouchbaseProperties properties, Cluster couchbaseCluster) {
    return couchbaseCluster.bucket(properties.getBucket().getName());
  }
}
