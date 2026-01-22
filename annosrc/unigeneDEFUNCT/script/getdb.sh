#!/bin/sh
set -e
. ./env.sh

echo "We no longer build UniGene!"

# ## These copies should replace the old files, ie, no need to explicitly 'rm'
# echo "copying files from local unigene/ to db/"
# cp ../human/$UGSOURCEDATE_human/unigenesrc.sqlite ../../db/chipmapsrc_human.sqlite
# cp ../mouse/$UGSOURCEDATE_mouse/unigenesrc.sqlite ../../db/chipmapsrc_mouse.sqlite
# cp ../rat/$UGSOURCEDATE_rat/unigenesrc.sqlite ../../db/chipmapsrc_rat.sqlite
# cp ../fly/$UGSOURCEDATE_fly/unigenesrc.sqlite ../../db/chipmapsrc_fly.sqlite
# cp ../fish/$UGSOURCEDATE_fish/unigenesrc.sqlite ../../db/chipmapsrc_zebrafish.sqlite
# cp ../canine/$UGSOURCEDATE_canine/unigenesrc.sqlite ../../db/chipmapsrc_canine.sqlite
# cp ../bovine/$UGSOURCEDATE_bovine/unigenesrc.sqlite ../../db/chipmapsrc_bovine.sqlite
# cp ../worm/$UGSOURCEDATE_worm/unigenesrc.sqlite ../../db/chipmapsrc_worm.sqlite
# cp ../pig/$UGSOURCEDATE_pig/unigenesrc.sqlite ../../db/chipmapsrc_pig.sqlite
# cp ../chicken/$UGSOURCEDATE_chicken/unigenesrc.sqlite ../../db/chipmapsrc_chicken.sqlite
# cp ../rhesus/$UGSOURCEDATE_rhesus/unigenesrc.sqlite ../../db/chipmapsrc_rhesus.sqlite
# cp ../xenopus/$UGSOURCEDATE_xenopus/unigenesrc.sqlite ../../db/chipmapsrc_xenopus.sqlite
# cp ../arabidopsis/$UGSOURCEDATE_arabidopsis/unigenesrc.sqlite ../../db/chipmapsrc_arabidopsis.sqlite
# cp ../anopheles/$UGSOURCEDATE_anopheles/unigenesrc.sqlite ../../db/chipmapsrc_anopheles.sqlite


# ##Remove old stuff for packages where we do not HAVE a unigenesrc.sqlite file.
# echo "removing chipmapsrc packages for organisms that don't have unigenesrc.sqlite"
# rm -f ../../db/chipmapsrc_ecoliK12.sqlite
# rm -f ../../db/chipmapsrc_ecoliSakai.sqlite
# rm -f ../../db/chipmapsrc_chimp.sqlite
# rm -f ../../db/chipmapsrc_yeastNCBI.sqlite
# rm -f ../../db/chipmapsrc_arabidopsisNCBI.sqlite
# echo "done with unigene build"
