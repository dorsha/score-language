#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
#   This flow will delete only the unused docker images
#   Inputs:
#       - dockerHost
#       - dockerUsername
#       - dockerPassword
#   Outputs:
#       - images_list_safe_to_delete - unused docker images
#   Results:
#       - SUCCESS
#       - FAILURE
####################################################
namespace: org.openscore.slang.integrations.docker.images.clear


imports:
 clear_content: org.openscore.slang.integrations.docker.images.clear
 linux_ops: org.openscore.slang.integrations.docker.linux
 get_content: org.openscore.slang.integrations.docker.images.get
 util: org.openscore.slang.integrations.docker.utility

flow:
  name: clear_docker_images_flow
  inputs:
    - dockerHost
    - dockerUsername
    - dockerPassword

  workflow:
    validate_linux_machine_ssh_access:
          do:
            linux_ops.validate_linux_machine_ssh_access_op:
              - host: dockerHost
              - username: dockerUsername
              - password: dockerPassword
    get_all_images:
      do:
        get_content.get_all_images_op:
          - host: dockerHost
          - username: dockerUsername
          - password: dockerPassword
      publish:
        - all_images_list: imageList
    get_used_images:
      do:
        get_content.get_used_images_flow:
          - dockerHost
          - dockerUsername
          - dockerPassword
      publish:
        - used_images_list: used_images_list
    substract_used_images:
      do:
        util.subtract_sets_op:
          - set_1: all_images_list
          - set_1_delimiter: "' '"
          - set_2: used_images_list
          - set_2_delimiter: "' '"
          - result_set_delimiter: "' '"
      publish:
        - images_list_safe_to_delete: result_set
    delete_images:
      do:
        clear_content.clear_docker_images_op:
          - host: dockerHost
          - username: dockerUsername
          - password: dockerPassword
          - images: images_list_safe_to_delete
      publish:
        - response
  outputs:
    - images_list_safe_to_delete
