#!/bin/bash

./jobcomp>jobcomp.log

mv cppdefs.h param.h croco Compile jobcomp.log /croco-exe
