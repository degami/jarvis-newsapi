#!/bin/bash
# Here you can create functions which will be available from the commands file
# You can also use here user variables defined in your config file
# To avoid conflicts, name your function like this
# pg_XX_myfunction () { }
# pg for PluGin
# XX is a short code for your plugin, ex: ww for Weather Wunderground
# You can use translations provided in the language folders functions.sh

jv_pg_newsapi_urlencode(){
    local value="$@"
    echo $(python -c "import urllib; print urllib.quote('''$value''')")
}

jv_pg_newsapi_get_data_from_json() {
    local jsondata=$1

    local title=$(echo $jsondata | jq ".title")
    local description=$(echo $jsondata | jq ".description")
    local source=$(echo $jsondata | jq ".source.name")
    local publishedAt=$(date --date "$(echo $jsondata | jq -r .publishedAt)" "+%d %B %Y")

    echo "$(pg_newsapi_lang source_is) $source"
    echo "$(pg_newsapi_lang title) $title"
    echo "$description"
    echo "$(pg_newsapi_lang publised_on) $publishedAt"
}

js_pg_newsapi_get_sources(){
    local jsondata=$(curl -s "https://newsapi.org/v2/sources?country=$jv_pg_newsapi_country&apiKey=$jv_pg_newsapi_appid")
    local counter=0
    for id in $(echo $jsondata | jq -r '.sources[] | "\(.id)"' ); do 
        echo $(echo $jsondata | jq ".sources[$counter].name"), id:  $id
        let counter=$counter+1
    done
    return 0
}

js_pg_newsapi_get_url(){
    if [[ $jv_pg_newsapi_sources != "" ]]; then
        echo "https://newsapi.org/v2/top-headlines?sources=$jv_pg_newsapi_sources&pageSize=$jv_pg_newsapi_pagesize&apiKey=$jv_pg_newsapi_appid"
    else
        echo "https://newsapi.org/v2/top-headlines?country=$jv_pg_newsapi_country&pageSize=$jv_pg_newsapi_pagesize&apiKey=$jv_pg_newsapi_appid"
    fi    
}

js_pg_newsapi_last_news(){
    local url=$(js_pg_newsapi_get_url)
    local jsondata=$(curl -s "$url")
    local total_results=$(echo $jsondata | jq ".totalResults")

    echo "$(pg_newsapi_lang i_got) $total_results $(pg_newsapi_lang results)"
    for i in $(seq 0 $(bc <<< "$total_results - 1") ); do 
        local item=$(echo $jsondata | jq ".articles[$i]")
        echo $(jv_pg_newsapi_get_data_from_json "$item"); 
    done
}

js_pg_newsapi_get_news(){
    local q="$@"
    local url="$(js_pg_newsapi_get_url)&q="$(jv_pg_newsapi_urlencode "$q")
    local jsondata=$(curl -s "$url")
    local total_results=$(echo $jsondata | jq ".totalResults")

    echo "$(pg_newsapi_lang i_got) $total_results $(pg_newsapi_lang results) $(pg_newsapi_lang on) $q"
    for i in $(seq 0 $(bc <<< "$total_results - 1") ); do 
        local item=$(echo $jsondata | jq ".articles[$i]")
        echo $(jv_pg_newsapi_get_data_from_json "$item"); 
    done
}