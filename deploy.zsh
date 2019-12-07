#!/usr/bin/env zsh

autoload colors; colors

print_whoops() {
    echo $fg[red] "Whoops! 😬" $reset_color
}

print_done() {
    echo $fg[green] "done"$reset_color
}

if [ ! -e env.sh ]; then
    print_whoops
    echo "You need to create \`env.sh\` (instructions in \`env.sh.example\`)."
    exit -1
fi

source env.sh

echo "Cleaning up. 🧹"
rm -rf docker-compose.yml nginx/nginx.conf nginx/conf.d tor/torrc

sites=(`sudo find ${LOCAL_SECRETS_PATH}/* -maxdepth 0 -type d`)
if (( ${#sites} == 0 )); then
    print_whoops
    echo "No Tor keys found in ${LOCAL_SECRETS_PATH}. Exiting."
    exit 1
fi

NGINX_PORT=10080
NGINX_PORTS=()

mkdir nginx/conf.d

cp templates/torrc.template tor/torrc

NGINX_PORTS_STRING="["
for dir in $sites; do
    HOSTNAME=`sudo cat $dir/hostname`;
    echo -n "Generating site data for \`${HOSTNAME}\` ..."
    cat templates/site.nginx.template | \
        sed "s/HOSTNAME/${HOSTNAME}/g" | \
        sed "s/BACKEND_APP/${BACKEND_APP}/g" | \
        sed "s/BACKEND_PORT/${BACKEND_PORT}/g" | \
        sed "s/NGINX_PORT/${NGINX_PORT}/g" \
        > nginx/conf.d/${HOSTNAME}

    echo "\nHiddenServiceDir /tor/${dir:t}/" >> tor/torrc
    echo "HiddenServicePort 80 proxy:${NGINX_PORT}" >> tor/torrc

    NGINX_PORTS+=$NGINX_PORT

    NGINX_PORTS_STRING+="\"${NGINX_PORT}\""

    if ((${#NGINX_PORTS} != ${#sites})); then
        NGINX_PORTS_STRING+=", "
    else
        NGINX_PORTS_STRING+="]"
    fi

    NGINX_PORT=$(($((NGINX_PORT))+1))

    print_done
done


echo -n "Generating docker-compose.yml ... "
cat templates/docker-compose-template.yml | \
    sed "s+LOCAL_SECRETS_PATH+${LOCAL_SECRETS_PATH}+g" | \
    sed "s/BACKEND_APP/${BACKEND_APP}/g" | \
    sed "s+BACKEND_IMAGE+${BACKEND_IMAGE}+g" | \
    sed "s/BACKEND_PORT/${BACKEND_PORT}/g" | \
    sed "s/NGINX_PORTS/${NGINX_PORTS_STRING}/g" \
    > docker-compose.yml
print_done

docker-compose up --build
