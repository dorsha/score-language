#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
#   This flow will create a db container
#   Inputs:
#       - host
#       - username
#       - password
#   Outputs:
#       - dbIp
#       - errorMessage
#   Results:
#       - SUCCESS
#       - FAILURE
####################################################
namespace: org.openscore.slang.integrations.docker.containers.create

imports:
 pull: org.openscore.slang.integrations.docker.images.pull
 create_content: org.openscore.slang.integrations.docker.containers.create
 get_content: org.openscore.slang.integrations.docker.containers.get
flow:
  name: create_db_container
  inputs:
    - host
    - username
    - password
  workflow:
    pull_mysql_image:
      do:
        pull.pull_image_op:
          - imageName: "'mysql'"
          - host
          - username
          - password
      publish:
        - errorMessage

    create_mysql_container:
      do:
        create_content.create_container_op:
          - imageID: "'mysql'"
          - containerName: "'mysqldb'"
          - cmdParams: "'-e MYSQL_ROOT_PASSWORD=pass -e MYSQL_DATABASE=boot -e MYSQL_USER=user -e MYSQL_PASSWORD=pass'"
          - host
          - username
          - password
      publish:
        - errorMessage

    get_db_ip:
      do:
        get_content.get_container_ip:
          - containerName: "'mysqldb'"
          - host
          - username
          - password
      publish:
        - dbIp
        - errorMessage

  outputs:
    - dbIp
    - errorMessage
