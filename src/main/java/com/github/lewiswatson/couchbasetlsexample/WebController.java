package com.github.lewiswatson.couchbasetlsexample;

import com.couchbase.client.java.Cluster;
import com.couchbase.client.java.query.QueryOptions;
import com.couchbase.client.java.query.QueryResult;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequiredArgsConstructor
public class WebController {

  private Cluster couchbaseCluster;

  @GetMapping("/")
  public String documentCount(
      @RequestParam(name="name", required=false, defaultValue="World") String name, Model model) {
    QueryResult queryResult = couchbaseCluster.query("SELECT * FROM data",
        QueryOptions.queryOptions().metrics(true));
    return "Number of documents in data bucket: "
        + queryResult.metaData().metrics().orElseThrow().resultCount();
  }

}
