#!/usr/bin/env zsh

if [ ! -e env.sh ]; then
    echo $fg[red] "Whoops! 😬" $reset_color
    echo "You need to create \`env.sh\` (instructions in \`env.sh.example\`)."
    exit -1
fi

source env.sh

TOR_V2_HOSTNAME=`sudo cat ${LOCAL_SECRETS_PATH}/v2/hostname`
TOR_V3_HOSTNAME=`sudo cat ${LOCAL_SECRETS_PATH}/v3/hostname`

autoload colors; colors

echo "Cleaning up. 🧹"
rm nginx.conf docker-compose.yml

print_done() {
    echo $fg[green] "done"$reset_color
}

echo -n "Generating nginx.conf ... "
cat templates/nginx.conf-template | \
    sed "s/TOR_V2_HOSTNAME/${TOR_V2_HOSTNAME}/g" | \
    sed "s/TOR_V3_HOSTNAME/${TOR_V3_HOSTNAME}/g" | \
    sed "s/BACKEND_APP/${BACKEND_APP}/g" | \
    sed "s/BACKEND_PORT/${BACKEND_PORT}/g" \
    > nginx.conf
print_done

echo -n "Generating docker-compose.yml ... "
cat templates/docker-compose-template.yml | \
    sed "s+LOCAL_SECRETS_PATH+${LOCAL_SECRETS_PATH}+g" | \
    sed "s/BACKEND_APP/${BACKEND_APP}/g" | \
    sed "s+BACKEND_IMAGE+${BACKEND_IMAGE}+g" | \
    sed "s/BACKEND_PORT/${BACKEND_PORT}/g" \
    > docker-compose.yml
print_done

docker-compose up
