#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
#   This operation will check if an application is up and running.
#   Inputs:
#       - host
#       - port
#       - max_seconds_to_wait
#   Outputs:
#       - errorMessage
#   Results:
#       - SUCCESS - succeeds if application is up
#       - FAILURE
####################################################

namespace: org.openscore.slang.technologies.network.verify

operations:
  - verify_app_is_up_op:
      inputs:
        - host
        - port
        - max_seconds_to_wait
      action:
        python_script: |
          import urllib2
          import time
          url = "http://" + host + ":" + port
          count = 0
          returnResult = False
          while (( count < max_seconds_to_wait ) and ( not returnResult )):
            try:
              result = urllib2.urlopen(url)
            except Exception :
               count = count + 1
               time.sleep(1)
            else:
                code = result.getcode()
                count = max_seconds_to_wait
                if code == 200 :
                  returnResult = True
      outputs:
        - errorMessage: "'Application is not Up , after ' + count + ' attempts to ping .'"
      results:
        - SUCCESS: returnResult == 'True'
        - FAILURE

