#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
#   This operation sends a simple email.
#   Inputs:
#       - host
#       - port
#       - from
#       - to
#       - cc - optional
#       - bcc - optional
#       - subject
#       - body
#       - htmlEmail - optional
#       - readReceipt - optional
#       - attachments - optional
#       - username - optional
#       - password - optional
#       - characterSet - optional
#       - contentTransferEncoding - optional
#       - delimiter - optional
#   Outputs:
#       -
#   Results:
#       - SUCCESS - succeeds if mail was sent successfully
#       - FAILURE
####################################################

namespace: org.openscore.slang.technologies.mail.send

operations:
  - send_mail_op:
      inputs:
        - hostname
        - port
        - from
        - to
        - cc: "''"
        - bcc: "''"
        - subject
        - body
        - htmlEmail: "'true'"
        - readReceipt: "'false'"
        - attachments: "''"
        - username: "''"
        - password: "''"
        - characterSet: "'UTF-8'"
        - contentTransferEncoding: "'base64'"
        - delimiter: "''"
      action:
        java_action:
          className: org.openscore.content.mail.actions.SendMailAction
          methodName: execute
      results:
        - SUCCESS: returnCode == '0'
        - FAILURE