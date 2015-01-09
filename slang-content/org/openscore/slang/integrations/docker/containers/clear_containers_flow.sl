#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
#   This flow will delete two docker containers
#   Inputs:
#       - dbContainerID
#       - linkedContainerID
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
 clear_content: org.openscore.slang.integrations.docker.containers.clear

flow:
  name: clear_containers_flow
  inputs:
    - dbContainerID
    - linkedContainerID
    - dockerHost
    - dockerUsername
    - dockerPassword
  workflow:
    clear_db_container:
      do:
        clear_content.clear_container:
          - containerID: "linkedContainerID"
          - dockerHost: "dockerHost"
          - dockerUsername: "dockerUsername"
          - dockerPassword: "dockerPassword"
    clear_linked_container:
      do:
        clear_content.clear_container:
          - containerID: "dbContainerID"
          - dockerHost: "dockerHost"
          - dockerUsername: "dockerUsername"
          - dockerPassword: "dockerPassword"
  outputs:
    - errorMessage
  results:
    - SUCCESS
    - FAILURE