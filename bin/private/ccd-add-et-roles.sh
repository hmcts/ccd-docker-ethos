#!/bin/bash

psql --username=ccd -f ${BASH_SOURCE%/*}/et_roles.sql idam
