#!/bin/bash

# set up the routing needed for the simulation
/setup.sh

# testsuite is checking implementation for 'compliance' by running both
# client and server codepaths with random test names; such unknown tests
# should report 'unsupported' by exiting with code 127
if [ ! -z "$TESTCASE" ]; then
    case "$TESTCASE" in
        "handshake"|"transfer"|"retry"|"goodput"|"resumption"|"multiconnect"|"http3"|"zerortt"|"chacha20")
            # expected to work
        ;;

        "versionnegotiation")
            # not yet supported
            exit 127
        ;;

        *)
            # unknown tests
            exit 127
        ;;
    esac
fi


if [ "$ROLE" == "client" ]; then
    # should never get here unless some bug in test harness
    echo "nginx is a server-side implementation"
    exit 127

elif [ "$ROLE" == "server" ]; then
    echo ">>> Starting nginx server..."
    /usr/sbin/nginx -V
    echo ">>> Parameters: $SERVER_PARAMS"
    echo ">>> Test case: $TESTCASE"

    export LD_LIBRARY_PATH=boringssl/build/ssl:boringssl/build/crypto

    case "$TESTCASE" in
        "retry")
            /usr/sbin/nginx -c /etc/nginx/nginx.conf.retry
        ;;
        "http3")
            /usr/sbin/nginx -c /etc/nginx/nginx.conf.http3
        ;;
        "transfer")
            /usr/sbin/nginx -c /etc/nginx/nginx.conf.nodebug
        ;;
        *)
            /usr/sbin/nginx -c /etc/nginx/nginx.conf
        ;;
    esac
fi
