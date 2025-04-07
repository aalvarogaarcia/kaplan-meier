#!/bin/bash

Rscript -e "shiny::runApp('~/kaplan-meier/TestApp',port=5127)"&

sleep 2

open "http://127.0.0.1:5127"
