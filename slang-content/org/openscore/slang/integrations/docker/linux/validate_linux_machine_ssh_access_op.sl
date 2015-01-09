#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
#   This operation will execute an empty SSH command
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
#       - response - linux welcome message
#   Results:
#       - SUCCESS
#       - FAILURE
####################################################

namespace: org.openscore.slang.integrations.docker.linux

operations:
    - validate_linux_machine_ssh_access_op:
        inputs:
          - host
          - port: "'22'"
          - username
          - password
          - privateKeyFile: "''"
          - command: "' '"
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
          - response: STDOUT
        results:
          - SUCCESS : returnCode == '0' and (not 'Error' in STDERR)
          - FAILURE