#!/bin/bash
# Here you can define translations to be used in the plugin functions file
# the below code is an sample to be reused:
# 1) uncomment to function below
# 2) replace XXX by your plugin name (short)
# 3) remove and add your own translations
# 4) you can the arguments $2, $3 passed to this function
# 5) in your plugin functions.sh file, use it like this:
#      say "$(pv_myplugin_lang the_answer_is "oui")"
#      => Jarvis: La réponse est oui

pg_newsapi_lang () {
    case "$1" in
        publised_on) echo "pubblicato il";;
        source_is) echo "la fonte è";;
        title) echo "titolo";;
        text) echo "testo";;
        i_got) echo "ci sono";;
        results) echo "risultati";;
        on) echo "su";;
    esac
} 