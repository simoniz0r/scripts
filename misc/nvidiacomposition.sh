#!/bin/bash
#I found this script somewhere on the internets and have been unable to refind it, so here it is so I never lose it.  If you wrote this, please let me know!

nvidia-settings --assign CurrentMetaMode="$(nvidia-settings -q CurrentMetaMode -t|tr '\n' ' '|sed -e 's/.*:: \(.*\)/\1\n/g' -e 's/}/, ForceCompositionPipeline = On}/g')" 
