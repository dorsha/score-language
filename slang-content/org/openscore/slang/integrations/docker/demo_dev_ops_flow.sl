#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
####################################################
#   This flow will pull two images and start two containers, check the application and send an email if something went wrong
#   Inputs:
#        - dockerHost
#        - dockerUsername
#        - dockerPassword
#        - emailHost
#        - emailPort
#        - emailSender
#        - emailRecipient
#   Outputs:
#       -
#   Results:
#       - SUCCESS - everything went fine
#       - FAILURE
####################################################

namespace: org.openscore.slang.integrations.docker

imports:
 create_content: org.openscore.slang.integrations.docker.containers.create
 pull: org.openscore.slang.integrations.docker.images.pull
 start_content: org.openscore.slang.integrations.docker.containers.start
 email: org.openscore.slang.technologies.mail.send
 app_test: org.openscore.slang.technologies.network.verify

flow:
  name: demo_dev_ops_flow
  inputs:
    - dockerHost
    - dockerUsername
    - dockerPassword
    - emailHost
    - emailPort
    - emailSender
    - emailRecipient
  workflow:
    create_db_container:
      do:
        create_content.create_db_container:
          - host: dockerHost
          - username: dockerUsername
          - password: dockerPassword
      publish:
        - db_IP: dbIp
        - errorMessage

    pull_app_image:
      do:
        pull.pull_image_op:
          - imageName: "'meirwa/spring-boot-tomcat-mysql-app'"
          - host: dockerHost
          - username: dockerUsername
          - password: dockerPassword
      publish:
        - errorMessage

    start_linked_container:
      do:
        start_content.start_linked_container_op:
          - dbContainerIp: db_IP
          - dbContainerName: "'mysqldb'"
          - imageName: "'meirwa/spring-boot-tomcat-mysql-app'"
          - containerName: "'spring-boot-tomcat-mysql-app'"
          - linkParams: "dbContainerName + ':mysql'"
          - cmdParams: "'-e DB_URL=' + dbContainerIp + ' -p 8080:8080'"
          - host: dockerHost
          - username: dockerUsername
          - password: dockerPassword
      publish:
        - containerID
        - errorMessage

    test_application:
      do:
        app_test.verify_app_is_up_op:
          - host: dockerHost
          - port: "'8080'"
          - max_seconds_to_wait: 20
      publish:
        - errorMessage

    on_failure:
      send_error_mail:
        do:
          email.send_mail_op:
            - hostname: emailHost
            - port: emailPort
            - from: emailSender
            - to: emailRecipient
            - subject: "'Flow failure'"
            - body: "'Operation failed with the following error:<br>' + errorMessage"
        navigate:
          SUCCESS: FAILURE
          FAILURE: FAILURE
