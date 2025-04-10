#!/bin/bash
if [ -d /opt/spring-petclinic ]; then
  rm -rf /opt/spring-petclinic/*
else
  mkdir -p /opt/spring-petclinic
fi
