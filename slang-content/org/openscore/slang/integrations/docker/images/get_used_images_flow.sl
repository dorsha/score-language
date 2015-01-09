#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
#   This flow will return a list of used docker images
#   Inputs:
#       - dockerHost
#       - dockerUsername
#       - dockerPassword
#   Outputs:
#       - used_images_list
####################################################
namespace: org.openscore.slang.integrations.docker.images.get

imports:
 get_content: org.openscore.slang.integrations.docker.images.get
 linux_ops: org.openscore.slang.integrations.docker.linux

flow:
  name: get_used_images_flow
  inputs:
    - dockerHost
    - dockerUsername
    - dockerPassword

  workflow:
    validate_linux_machine_ssh_access_op:
          do:
            linux_ops.validate_linux_machine_ssh_access_op:
              - host: dockerHost
              - username: dockerUsername
              - password: dockerPassword
    get_used_images_op:
      do:
        get_content.get_used_images_op:
          - host: dockerHost
          - username: dockerUsername
          - password: dockerPassword
      publish:
        - used_images_list: imageList
  outputs:
    - used_images_list
