#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
#   This operation will create a docker container
#   Inputs:
#       - imageID - docker image that will be assigned to the container
#       - containerName
#       - cmdParams
#       - host
#       - port - optional
#       - username
#       - password
#       - privateKeyFile - optional
#       - arguments - optional
#       - characterSet - optional
#       - pty - optional
#       - timeout - optional
#       - closeSession - optional
#   Outputs:
#       - dbContainerID
#       - errorMessage
#   Results:
#       - SUCCESS
#       - FAILURE
####################################################

namespace: org.openscore.slang.integrations.docker.containers.create

operations:

- create_container_op:
      inputs:
        - imageID
        - containerName
        - cmdParams
        - host
        - port: "'22'"
        - username
        - password
        - privateKeyFile: "''"
        - command: "'docker run --name ' + containerName + ' ' +cmdParams + ' -d ' + imageID"
        - arguments: "''"
        - characterSet: "'UTF-8'"
        - pty: "'false'"
        - timeout: "'90000'"
        - closeSession: "'false'"
      action:
        java_action:
          className: org.openscore.content.ssh.actions.SSHShellCommandAction
          methodName: runSshShellCommand
      outputs:
        - dbContainerID: returnResult
        - errorMessage: STDERR if returnCode == '0' else returnResult
      results:
        - SUCCESS : returnCode == '0' and (not 'Error' in STDERR)
        - FAILURE