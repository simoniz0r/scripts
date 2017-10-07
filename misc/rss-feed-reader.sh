#!/bin/bash
# A simple script that parses raw RSS feeds into a nice, readable format.
# Base script from: http://www.linuxjournal.com/content/parsing-rss-news-feed-bash-script
# Modified by simonizor



xmlgetnext () {
   local IFS='>'
   read -d '<' TAG VALUE
}

rssparse () {
cat $1 | while xmlgetnext ; do
case $TAG in
    'item')
        title=''
        link=''
        pubDate=''
        description=''
        ;;
    'title')
        title="$(echo $VALUE | sed 's%&quot;%"%g;s%&amp;%\&%g')"
        ;;
    'link')
        link="$(echo $VALUE | sed 's%&amp;%\&%g')"
        ;;
    'pubDate')
        # convert pubDate format for <time datetime="">
        datetime=$( date --date "$VALUE" --iso-8601=minutes )
        pubDate=$( date --date "$VALUE" '+%D %H:%M%P' )
        ;;
    'description')
        # convert '&lt;' and '&gt;' to '<' and '>'
        description=$( echo "$VALUE" | sed -e 's%/&gt;%}%g' -e 's%/&lt;%}%g' | sed 's%&amp;#8217;%%g;s%&quot;%"%g;s%&amp;%\&%g' | cut -f2 -d"}" | cut -f1 -d"&" | sed 's%\[%...%g' )
        ;;
    '/item')
        cat<<EOF
$(tput setaf 4)$title$(tput sgr0)
$link
$description
$datetime $pubDate

EOF
        ;;
    esac
done
}

case $1 in
    -h)
        RSS_FEEDS="
        https://news.ycombinator.com/rss,Hackernews
        "
        ;;
    -p)
        RSS_FEEDS="
        http://www.phoronix.com/rss.php
        "
        ;;
    -o)
        RSS_FEEDS="
        http://feeds.feedburner.com/d0od,OMG!Ubuntu
        "
        ;;
    -w)
        RSS_FEEDS="
        http://feeds2.feedburner.com/webupd8,Webupd8
        "
        ;;
    *)
        RSS_FEEDS="
        http://feeds2.feedburner.com/webupd8,Webupd8
        http://feeds.feedburner.com/d0od,OMG!Ubuntu
        http://www.phoronix.com/rss.php
        https://news.ycombinator.com/rss,Hackernews
        "
        ;;
esac
for feed in $RSS_FEEDS; do
    FEED_NAME="$(echo "$feed" | cut -f2- -d"," | cut -f3- -d"/" | cut -f1 -d"?")"
    FEED_URL="$(echo "$feed" | cut -f1 -d",")"
    echo "$(tput bold)$(tput setaf 4)-- $FEED_NAME --$(tput sgr0)"
    echo
    wget --quiet "$FEED_URL" -O - | rssparse | cat | sed '/<*..*>/d'
    echo
done | less -R
