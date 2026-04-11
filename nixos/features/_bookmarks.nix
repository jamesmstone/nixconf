[
  {
    name = "Bookmarks Toolbar";
    toolbar = true;
    bookmarks = [
      {
        name = "Draw";
        url = "https://excalidraw.com/";
      }
      {
        name = "ToggleReactScan";
        url = "javascript:(function(){let v=localStorage.getItem('react-scan')==='true';localStorage.setItem('react-scan',(!v).toString());alert('React-scan is now '+((!v)?'enabled':'disabled')+'. Refresh the page to apply changes.')})();";
      }
      {
        name = "Archive";
        bookmarks = [
          {
            name = "Load Archive";
            url = "javascript:void(location.href='https://web.archive.org/web/'+prompt(%22url:%22,location.href))";
          }
          {
            name = "Save to Archive";
            url = "javascript:void(location.href='https://web.archive.org/save/'+location.href)";
          }
          {
            name = "archive.today";
            url = "javascript:void(open('https://archive.today/?run=1&url='+encodeURIComponent(document.location)))";
          }
        ];
      }
      {
        name = "";
        url = "https://chat.beeper.com/";
      }
      #      {
      #        name = "";
      #        url = "https://news.t0.vc/";
      #      }
      {
        name = "";
        url = "https://teams.microsoft.com/";
      }
      {
        name = "Confluence";
        url = "https://traditionasia.atlassian.net/wiki/home";
      }
      {
        name = "Rates";
        bookmarks = [
          {
            name = "daily";
            url = "https://meet.google.com/zeg-miat-bix?pli=1&authuser=1";
          }
          {
            name = "gitlab: service";
            url = "https://gitlab.traditionasia.com/utc/utc-rates-service/";
          }
          {
            name = "gitlab: main-app";
            url = "https://gitlab.traditionasia.com/utc/utc-rates-main-app/";
          }
          {
            name = "Jira";
            url = "https://traditionasia.atlassian.net/jira/software/projects/UTCR/boards/32/backlog";
          }
          {
            name = "Local dev";
            url = "https://localhost:3000/#/test?user=timmy.cm@traditionasia.com&pass=testtest";
          }
          {
            name = "Environment";
            url = "https://traditionasia.atlassian.net/wiki/spaces/UT/pages/1963327502/Environments";
          }
          {
            name = "Versions";
            url = "https://traditionasia.atlassian.net/wiki/spaces/UT/pages/1963524107/Versions";
          }
          {
            name = "Kibana logs";
            url = "https://vpc-ctc-es6-dev-6fpc67kgyjy3ywqd4sygy3xfra.eu-central-1.es.amazonaws.com/_plugin/kibana/app/kibana#/discover?_g=(refreshInterval:(pause:!f,value:5000),time:(from:now-4h,mode:quick,to:now))&_a=(columns:!(log_processed.level,log_processed.message),filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!t,index:fa38f5d0-4e06-11ec-8db3-f1363fd810e5,key:kubernetes.container_name,negate:!f,params:(query:rates-date-service,type:phrase),type:phrase,value:rates-date-service),query:(match:(kubernetes.container_name:(query:rates-date-service,type:phrase)))),('$state':(store:appState),meta:(alias:!n,disabled:!t,index:fa38f5d0-4e06-11ec-8db3-f1363fd810e5,key:kubernetes.container_name,negate:!f,params:(query:utc-rates-markitwire-service,type:phrase),type:phrase,value:utc-rates-markitwire-service),query:(match:(kubernetes.container_name:(query:utc-rates-markitwire-service,type:phrase)))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:fa38f5d0-4e06-11ec-8db3-f1363fd810e5,key:kubernetes.container_name,negate:!f,params:(query:utc-rates-service,type:phrase),type:phrase,value:utc-rates-service),query:(match:(kubernetes.container_name:(query:utc-rates-service,type:phrase)))),('$state':(store:appState),meta:(alias:!n,disabled:!t,index:fa38f5d0-4e06-11ec-8db3-f1363fd810e5,key:log_processed.message,negate:!f,params:!('trying%20to%20subscribe%20to'),type:phrases,value:'trying%20to%20subscribe%20to'),query:(bool:(minimum_should_match:1,should:!((match_phrase:(log_processed.message:'trying%20to%20subscribe%20to')))))),('$state':(store:appState),meta:(alias:!n,disabled:!t,index:fa38f5d0-4e06-11ec-8db3-f1363fd810e5,key:kubernetes.namespace_name,negate:!f,params:(query:utcr-test,type:phrase),type:phrase,value:utcr-test),query:(match:(kubernetes.namespace_name:(query:utcr-test,type:phrase)))),('$state':(store:appState),meta:(alias:!n,disabled:!t,index:fa38f5d0-4e06-11ec-8db3-f1363fd810e5,key:log_processed.level,negate:!f,params:(query:ERROR,type:phrase),type:phrase,value:ERROR),query:(match:(log_processed.level:(query:ERROR,type:phrase)))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:ctc-app-logs,key:kubernetes.namespace_name,negate:!f,params:(query:utcr-dev,type:phrase),type:phrase,value:utcr-dev),query:(match:(kubernetes.namespace_name:(query:utcr-dev,type:phrase)))),('$state':(store:appState),exists:(field:log_processed.message),meta:(alias:!n,disabled:!f,index:ctc-app-logs,key:log_processed.message,negate:!f,type:exists,value:exists))),index:ctc-app-logs,interval:auto,query:(language:lucene,query:''),sort:!('@timestamp',desc))";
          }

          {
            name = "Dev";
            bookmarks = [
              {
                name = "Sample app";
                url = "https://utcr-storybook.traditionasia-istanbul.com/";
              }
              {
                name = "Main app";
                url = "https://utcrates-site-dev.traditionasia-istanbul.com/";
              }
              {
                name = "Ref data";
                url = "https://utcrates-refdata-dev.traditionasia-istanbul.com/";
              }
              {
                name = "Rates service";
                url = "https://utcrates-api-dev.traditionasia-istanbul.com";
              }
              {
                name = "Brokerage service";
                url = "https://utcrates-brokerage-dev.traditionasia-istanbul.com/";
              }
              {
                name = "Brokerage UI";
                url = "https://utcrates-brokerage-ui-dev.traditionasia-istanbul.com/";
              }
              {
                name = "Dates service (external)";
                url = "https://utcrates-date-dev.traditionasia-istanbul.com";
              }
              {
                name = "ETP service (external/grpc)";
                url = "utcrates-reporting-service-dev.traditionasia-istanbul.com:443";
              }
            ];
          }
          {
            name = "Test";
            bookmarks = [
              {
                name = "Sample app";
                url = "https://utcr-storybook-test.traditionasia-istanbul.com/";
              }
              {
                name = "Main app";
                url = "https://utcrates-site-test.traditionasia-istanbul.com/";
              }
              {
                name = "Ref data";
                url = "https://utcrates-refdata-test.traditionasia-istanbul.com/";
              }
              {
                name = "Rates service";
                url = "https://utcrates-api-test.traditionasia-istanbul.com";
              }
              {
                name = "Brokerage service";
                url = "https://utcrates-brokerage-test.traditionasia-istanbul.com/";
              }
              {
                name = "Brokerage UI";
                url = "https://utcrates-brokerage-ui-test.traditionasia-istanbul.com/";
              }
              {
                name = "Dates service (external)";
                url = "https://utcrates-date-test.traditionasia-istanbul.com";
              }
              {
                name = "ETP service (external/grpc)";
                url = "utcrates-reporting-service-test.traditionasia-istanbul.com:443";
              }
            ];
          }
          {
            name = "Uat";
            bookmarks = [
              {
                name = "Sample app";
                url = "https://utcr-storybook-uat.traditionasia-istanbul.com/";
              }
              {
                name = "Main app";
                url = "https://utcrates-site-uat.traditionasia-istanbul.com/";
              }
              {
                name = "Ref data";
                url = "https://utcrates-refdata-uat.traditionasia-istanbul.com/";
              }
              {
                name = "Rates service";
                url = "https://utcrates-api-uat.traditionasia-istanbul.com";
              }
              {
                name = "Brokerage service";
                url = "https://utcrates-brokerage-uat.traditionasia-istanbul.com/";
              }
              {
                name = "Brokerage UI";
                url = "https://utcrates-brokerage-ui-uat.traditionasia-istanbul.com/";
              }
              {
                name = "Dates service (external)";
                url = "https://utcrates-date-uat.traditionasia-istanbul.com";
              }
              {
                name = "ETP service (external/grpc)";
                url = "utcrates-reporting-service-uat.traditionasia-istanbul.com:443";
              }
            ];
          }
          {
            name = "Live";
            bookmarks = [
              {
                name = "Main app";
                url = "https://utcrates-site-live.tradasiahub.com/";
              }
              {
                name = "Ref data";
                url = "https://utcrates-refdata-live.tradasiahub.com/";
              }
              {
                name = "Rates service";
                url = "https://utcrates-api-live.tradasiahub.com";
              }
              {
                name = "Brokerage service";
                url = "https://utcrates-brokerage-live.tradasiahub.com/";
              }
              {
                name = "Brokerage UI";
                url = "https://utcrates-brokerage-ui-live.tradasiahub.com/";
              }
              {
                name = "Dates service (external)";
                url = "https://utcrates-date-live.tradasiahub.com";
              }
              {
                name = "ETP service (external/grpc)";
                url = "utcrates-reporting-service-live.tradasiahub.com:443";
              }
            ];
          }
        ];
      }
      {
        name = "ST5";
        bookmarks = [
          {
            name = "ST5 Jira";
            url = "https://traditionasia.atlassian.net/jira/software/projects/ST5/boards/31?label=BrokerApp%2CBrokerService";
          }
          {
            name = "Gitlab";
            url = "https://gitlab.traditionasia.com/swaptrader";
          }
          {
            name = "Balsamiq";
            url = "https://balsamiq.cloud/sutkzd1/py4523n/rD8F7";
          }
        ];
      }
      {
        name = "Archimedes";
        bookmarks = [
          {
            name = "Gitlab";
            url = "https://gitlab.traditionasia.com/swaptrader/archimedes/";
          }
          {
            name = "Lab";
            url = "https://archimedes.traditionasia-lab.com/";
          }
        ];
      }
      {
        name = "Whiteboard";
        bookmarks = [
          {
            name = "Mono Repo";
            url = "https://gitlab.traditionasia.com/tfxdeal-whiteboard/whiteboard-mono";
          }
          {
            name = "WB Jira";
            url = "https://traditionasia.atlassian.net/jira/software/projects/TFXWB/boards/30/backlog";
          }
          {
            name = "WB weekly";
            url = "https://meet.google.com/iqc-riqs-rfo";
          }
          {
            name = "WB DEV";
            url = "https://tfxdeal-whiteboard.traditionasia-istanbul.com/login";
          }
          {
            name = "Environments";
            url = "https://traditionasia.atlassian.net/wiki/spaces/TFXWB/pages/2348515329/Environments+K8s";
          }
          {
            name = "Lucid";
            url = "https://lucid.app/lucidchart/08e1544e-3225-4ca0-ac49-335f445a82f3/edit?invitationId=inv_d5be3e88-34c5-4d6f-b930-85463ed6bef6&page=mFRjUtXDR9g5#";
          }

          {
            name = "Monitoring";
            bookmarks = [
              {
                name = "CPU/Memory/Network per pod";
                url = "https://grafana.traditionctc.com/d/6581e46e4e5c7ba40a07646395ef7b23/kubernetes-compute-resources-pod?orgId=1&refresh=10s&var-datasource=default&var-cluster=&var-namespace=utcr-live&var-pod=utc-rates-service-6f6d94ddf9-gnw59&from=1740124792650&to=1740128392650";
              }
              {
                name = "JVM Metrics";
                url = "https://grafana.traditionctc.com/d/c29a0673-aa13-412a-b7e7-07946cdc78f3/kamon-2-x-system-metrics-dashboard?orgId=1&refresh=1m&var-PROMETHEUS_DS=Prometheus&var-namespace=utcr-live&var-job=utc-rates-service-svc&var-instance=10.193.17.102%3A8122&var-interval=1h&from=1740106761030&to=1740128361030";
              }
              {
                name = "RabbitMQ Overview";
                url = "https://grafana.traditionctc.com/d/Kn5xm-gZk/rabbitmq-overview?orgId=1&from=1740106866429&to=1740128466429";
              }
            ];
          }
          {
            name = "3.0";
            bookmarks = [
              {
                name = "Dev";
                bookmarks = [
                  {
                    name = "sgp";
                    url = "https://tfxdeal-whiteboard.traditionasia-istanbul.com";
                  }
                ];
              }
              {
                name = "Test";
                bookmarks = [
                  {
                    name = "sgp";
                    url = "https://tfxdeal-whiteboard-sg-test.traditionasia-istanbul.com";
                  }
                  {
                    name = "hk";
                    url = "https://tfxdeal-whiteboard-hk-test.traditionasia-istanbul.com";
                  }
                  {
                    name = "ldn";
                    url = "https://tfxdeal-whiteboard-ldn-test.traditionasia-istanbul.com";
                  }
                ];
              }
              {
                name = "UAT";
                bookmarks = [
                  {
                    name = "sgp";
                    url = "https://whiteboard-sg-uat.traditionasia.com";
                  }
                  {
                    name = "hk";
                    url = "https://whiteboard-hk-uat.traditionasia.com";
                  }
                  {
                    name = "ldn";
                    url = "https://whiteboard-ldn-uat.traditionasia.com";
                  }
                ];
              }
              {
                name = "LIVE";
                bookmarks = [
                  {
                    name = "sgp";
                    url = "https://tfxdeal-whiteboard-sg-live.tradasiahub.com";
                  }
                  {
                    name = "hk";
                    url = "https://tfxdeal-whiteboard-hk-live.tradasiahub.com";
                  }
                  {
                    name = "ldn";
                    url = "https://tfxdeal-whiteboard-ldn-live-ext.tradasiahub.com";
                  }
                  {
                    name = "argo";
                    url = "https://argocd.traditionasia-istanbul.com/applications/argocd/uwbfx-whiteboard-mainservice-test?operation=false&resource=&node=%2FPod%2Fuwbfx-test%2Fuwbfx-whiteboard-mainservice-69597d4d9c-vdzl2%2F0&tab=logs";
                  }
                  {
                    name = "kibana";
                    url = "https://vpc-ctc-es6-dev-6fpc67kgyjy3ywqd4sygy3xfra.eu-central-1.es.amazonaws.com/_plugin/kibana/app/kibana#/discover/fluentbit?_g=(refreshInterval:(pause:!t,value:0),time:(from:now-15m,mode:quick,to:now))&_a=(columns:!(_source),filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:ctc-app-logs,key:kubernetes.namespace_name,negate:!f,params:(query:uwbfx-test,type:phrase),type:phrase,value:uwbfx-test),query:(match:(kubernetes.namespace_name:(query:uwbfx-test,type:phrase)))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:ctc-app-logs,key:kubernetes.container_name,negate:!f,params:(query:uwbfx-whiteboard-mainservice,type:phrase),type:phrase,value:uwbfx-whiteboard-mainservice),query:(match:(kubernetes.container_name:(query:uwbfx-whiteboard-mainservice,type:phrase))))),index:ctc-app-logs,interval:auto,query:(language:lucene,query:''),sort:!('@timestamp',desc))";
                  }
                ];
              }
            ];
          }

          {
            name = "wb-test";
            url = "https://whiteboard-test.traditionasia-lab.com/login?redirectUrl=%2F";
          }
          {
            name = "wb-uat";
            url = "https://whiteboard-uat.traditionasia-lab.com/";
          }
          {
            name = "wb-live";
            url = "https://whiteboard.traditionasia-sys.com/login?redirectUrl=%2F";
          }
          {
            name = "wb-live-ldn";
            url = "https://whiteboard-ldn.traditionasia-sys.com";
          }
        ];
      }
      {
        name = "UTC FX";
        bookmarks = [
          {
            name = "UTC FX Dev Dealsheet";
            url = "https://utcfx-dealsheet-dev.traditionasia-istanbul.com/#/dashboard";
          }
        ];
      }
      {
        name = "JBOS";
        bookmarks = [
          {
            name = "Environments";
            bookmarks = [
              {
                name = "Dev";
                url = "https://dev-jtc-back.traditionasia.com/";
              }
              {
                name = "Test";
                url = "https://test-jtc-back.traditionasia.com/";
              }
              {
                name = "UAT";
                url = "https://uat-jtc-back.traditionasia.com/";
              }
            ];
          }
        ];
      }
      {
        name = "Scrapper charts";
        url = "http://172.26.32.100:8282/";
      }
      {
        name = "Halo";
        url = "https://traditionasia.haloitsm.com/portal/";
      }
      {
        name = "Dozzle Lab";
        url = "https://dozzle.monitoring.traditionasia-lab.com/";
      }
      {
        name = "Dozzle Sys";
        url = "https://dozzle.monitoring.traditionasia-sys.com/";
      }
      {
        name = "Vapi";
        url = "https://vapi.ai/?demo=true&shareKey=02563ebe-7d05-419f-8935-499ec332753f&assistantId=1944be4c-fab3-47b4-9ae8-18cae1c00099";
      }
      {
        name = "TC Services";
        bookmarks = [
          {
            name = "TCScriptWeb Frontend";
            bookmarks = [
              {
                name = "Dev";
                url = "https://tcscriptweb-dev.traditionasia-istanbul.com";
              }
              {
                name = "Test";
                url = "https://tcscriptweb-test.traditionasia-istanbul.com";
              }
              {
                name = "Uat";
                url = "https://tcscriptweb-uat.traditionasia-istanbul.com";
              }
              {
                name = "Live";
                url = "https://tcscriptweb-live.tradasiahub.com";
              }
            ];
          }
          {
            name = "TCScriptWeb Backend";
            bookmarks = [
              {
                name = "Dev";
                url = "https://tcscriptwebservice-dev.traditionasia-istanbul.com/api/active-pages-and-scripts?instance={instance_name}&token={token}";
              }
              {
                name = "Test";
                url = "https://tcscriptwebservice-test.traditionasia-istanbul.com/api/active-pages-and-scripts?instance={instance_name}&token={token}";
              }
              {
                name = "Uat";
                url = "https://tcscriptwebservice-uat.traditionasia-istanbul.com/api/active-pages-and-scripts?instance={instance_name}&token={token}";
              }
              {
                name = "Live";
                url = "https://tcscriptwebservice-live.tradasiahub.com/api/active-pages-and-scripts?instance={instance_name}&token={token}";
              }
            ];
          }
          {
            name = "TcWebAdmin";
            bookmarks = [
              {
                name = "Dev";
                bookmarks = [
                  {
                    name = "External";
                    url = "https://tcwebadmin-dev.traditionasia-istanbul.com";
                  }
                  {
                    name = "Internal";
                    url = "http://tradconnect-tcwebadmin-svc:9000";
                  }
                ];
              }
              {
                name = "Test";
                bookmarks = [
                  {
                    name = "External";
                    url = "https://tcwebadmin-test.traditionasia-istanbul.com";
                  }
                  {
                    name = "Internal";
                    url = "http://tradconnect-tcwebadmin-svc:9000";
                  }
                ];
              }
              {
                name = "Uat";
                bookmarks = [
                  {
                    name = "External";
                    url = "https://tcwebadmin-uat.traditionasia-istanbul.com";
                  }
                  {
                    name = "Internal";
                    url = "http://tradconnect-tcwebadmin-svc:9000";
                  }
                ];
              }
              {
                name = "Live";
                bookmarks = [
                  {
                    name = "External";
                    url = "https://tcwebadmin-live.tradasiahub.com";
                  }
                  {
                    name = "Internal";
                    url = "http://tradconnect-tcwebadmin-svc:9000";
                  }
                ];
              }
            ];
          }
          {
            name = "TCWebView";
            bookmarks = [
              {
                name = "Dev";
                url = "https://tcwebview-dev.traditionasia-istanbul.com";
              }
              {
                name = "Test";
                url = "https://tcwebview-test.traditionasia-istanbul.com";
              }
              {
                name = "Uat";
                url = "https://tcwebview-uat.traditionasia-istanbul.com";
              }
              {
                name = "Live";
                url = "https://tcwebview-live.tradasiahub.com";
              }
            ];
          }
          {
            name = "TCRedisInfo";
            bookmarks = [
              {
                name = "Dev";
                url = "https://tcredisservice-dev.traditionasia-istanbul.com";
              }
              {
                name = "Test";
                url = "https://tcredisservice-test.traditionasia-istanbul.com";
              }
              {
                name = "Uat";
                bookmarks = [
                  {
                    name = "Service 1";
                    url = "https://tcredisservice1-uat.traditionasia-istanbul.com";
                  }
                  {
                    name = "Service 2";
                    url = "https://tcredisservice2-uat.traditionasia-istanbul.com";
                  }
                ];
              }
              {
                name = "Live";
                bookmarks = [
                  {
                    name = "Service 1";
                    url = "https://tcredisservice1-live.tradasiahub.com";
                  }
                  {
                    name = "Service 2";
                    url = "https://tcredisservice2-live.tradasiahub.com";
                  }
                ];
              }
            ];
          }
        ];
      }
      {
        name = "Ports";
        url = "https://traditionasia-my.sharepoint.com/:x:/p/andrew_blakie/IQALLsjf20iiQoJNdFTRkJnYAe4NiROV_5Tbci1D-DRQYkw?e=o3QA6v";
      }
    ];
  }
]
