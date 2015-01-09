#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
#   This operation will pull a docker image
#   Inputs:
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
#       - returnResult
#       - errorMessage
#   Results:
#       - SUCCESS
#       - FAILURE
####################################################

namespace: org.openscore.slang.integrations.docker.images.pull

operations:

 - pull_image_op:
    inputs:
        - imageName
        - host
        - port: "'22'"
        - username
        - password
        - privateKeyFile: "''"
        - command: "'docker pull ' + imageName"
        - arguments: "''"
        - characterSet : "'UTF-8'"
        - pty: "'false'"
        - timeout: "'30000000'"
        - closeSession: "'false'"
    action:
        java_action:
          className: org.openscore.content.ssh.actions.SSHShellCommandAction
          methodName: runSshShellCommand
    outputs:
        - returnResult: returnResult
        - errorMessage: STDERR if returnCode == '0' else returnResult
    results:
        - SUCCESS : returnCode == '0' and (not 'Error' in STDERR)
        - FAILURE