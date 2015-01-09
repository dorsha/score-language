#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
#   This operation will start a linked container
#   Inputs:
#       - dbContainerIp
#       - dbContainerName
#       - imageName
#       - containerName
#       - linkParams
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
#       - containerID
#       - errorMessage
#   Results:
#       - SUCCESS
#       - FAILURE
####################################################

namespace: org.openscore.slang.integrations.docker.containers.start

operations:
    - start_linked_container_op:
         inputs:
           - dbContainerIp
           - dbContainerName
           - imageName
           - containerName
           - linkParams
           - cmdParams
           - host
           - port: "'22'"
           - username
           - password
           - privateKeyFile: "''"
           - arguments: "''"
           - command: "'docker run --name ' + containerName + ' --link ' + linkParams + ' ' + cmdParams + ' -d ' + imageName"
           - characterSet: "'UTF-8'"
           - pty: "'false'"
           - timeout: "'90000'"
           - closeSession: "'false'"
         action:
           java_action:
             className: org.openscore.content.ssh.actions.SSHShellCommandAction
             methodName: runSshShellCommand
         outputs:
           - containerID: returnResult
           - errorMessage: STDERR if returnCode == '0' else returnResult
         results:
           - SUCCESS : returnCode == '0' and (not 'Error' in STDERR)
           - FAILURE