#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
#   This flow will delete a docker container
#   Inputs:
#       - containerID
#       - dockerHost
#       - dockerUsername
#       - dockerPassword
#   Outputs:
#       - errorMessage
#   Results:
#       - SUCCESS
#       - FAILURE
####################################################

namespace: org.openscore.slang.integrations.docker.containers.clear

imports:
 stop_content: org.openscore.slang.integrations.docker.containers.stop
 delete_content: org.openscore.slang.integrations.docker.containers.delete
flow:
  name: clear_container
  inputs:
    - containerID
    - dockerHost
    - dockerUsername
    - dockerPassword
  workflow:
    stop_container:
      do:
        stop_content.stop_container_op:
          - containerID: containerID
          - host: dockerHost
          - username: dockerUsername
          - password: dockerPassword
      publish:
        - errorMessage

    delete_container:
      do:
        delete_content.delete_container_op:
          - containerID: containerID
          - host: dockerHost
          - username: dockerUsername
          - password: dockerPassword
      publish:
        - errorMessage

  outputs:
    - errorMessage
