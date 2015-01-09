#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
#   This flow will delete unused images if the disk space on a linux machine is greater than a given input
#   Inputs:
#       - dockerHost
#       - dockerUsername
#       - dockerPassword
#       - percentage - disk space on the linux machine is compared to this number
#   Outputs:
#       - images_list_safe_to_delete - unused docker images
#   Results:
#       - SUCCESS
#       - FAILURE
####################################################

namespace: org.openscore.slang.integrations.docker.health_checks

imports:
 util: org.openscore.slang.integrations.docker.utility
 linux: org.openscore.slang.integrations.docker.linux
 clear_content: org.openscore.slang.integrations.docker.images.clear

flow:
  name: diskspace_heath_check_flow
  inputs:
    - dockerHost
    - dockerUsername
    - dockerPassword
    - percentage

  workflow:
    validate_linux_machine_ssh_access:
      do:
        linux.validate_linux_machine_ssh_access_op:
          - host: dockerHost
          - username: dockerUsername
          - password: dockerPassword
    check_disk_space:
      do:
        linux.check_linux_disk_space_op:
          - host: dockerHost
          - username: dockerUsername
          - password: dockerPassword
      publish:
        - diskSpace
    check_availability:
      do:
        util.less_than_percentage_op:
          - first_percentage: diskSpace
          - second_percentage: percentage
      navigate:
        SUCCESS: SUCCESS
        FAILURE: clear_docker_images
    clear_docker_images:
      do:
        clear_content.clear_docker_images_flow:
          - dockerHost
          - dockerUsername
          - dockerPassword
      publish:
        - images_list_safe_to_delete
      navigate:
        SUCCESS: SUCCESS
        FAILURE: FAILURE

