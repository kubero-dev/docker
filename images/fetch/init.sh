#!/bin/sh

set -e

#echo "========= load deployment keys"
#eval `ssh-agent`
#ssh-add /root/.ssh/*
#ssh-keyscan github.com >>~/.ssh/known_hosts

if [ -z "$GIT_REPOSITORY" ]; then
    echo "GIT_REPOSITORY is not set"
    exit 1
fi

## if GIT_BRANCH is set use it as GIT_REF
if [ -z "$GIT_REF" ]; then
    if [ -z "$GIT_BRANCH" ]; then
        echo "GIT_REF is not set"
        exit 1
    else
        GIT_REF=$GIT_BRANCH
    fi
fi

echo "========== debug"
echo "GIT_REPOSITORY: $GIT_REPOSITORY"
echo "GIT_REF: $GIT_REF"
echo "KUBERO_BUILDPACK_DEFAULT_BUILD_CMD: $KUBERO_BUILDPACK_DEFAULT_BUILD_CMD"
echo "KUBERO_BUILDPACK_DEFAULT_RUN_CMD: $KUBERO_BUILDPACK_DEFAULT_RUN_CMD"
echo "User:" `whoami`
echo "ID:" `id`
echo "Home:" $HOME
echo "PWD:" `pwd`

# prepare ssh keys
echo "========== copy ssh keys"
mkdir -p ~/.ssh
chmod -v 700 ~/.ssh
cat /home/kubero/.ssh-mounted/deploykey > ~/.ssh/deploykey
chmod -v 600 ~/.ssh/deploykey
#chmod -v 644 ~/.ssh/*.pub
touch ~/.ssh/known_hosts
chmod -v 644 ~/.ssh/known_hosts

echo "========== whipe the app dir"
rm -rf /app/* /app/.* >> /dev/null 2>&1 || true
echo "Done"

echo "========== Clone Repository from $GIT_REPOSITORY"
cd /app
git config --global --add safe.directory /app #Mark git directory as safe
git clone --recurse-submodules $GIT_REPOSITORY .
git checkout $GIT_REF
#git log -n1 --pretty=format:'export REF_NAMES="%D"%nexport COMMIT=%H%nexport AUTHOR=%an%nexport AUTHOR_EMAIL=%ae%nexport DATE="%ad"%nexport SUBJECT="%s"%nexport BODY="%b"%n' > kubero_commit.env

rm -rf .git

echo "========== write startupscripts based on Procfile"
if [ ! -f init_build.sh ]; then
    if [ -f Procfile ]; then
        BUILD_CMD=$(cat Procfile | grep build | awk -F  ": " '{print $2}')
    else
        BUILD_CMD=$KUBERO_BUILDPACK_DEFAULT_BUILD_CMD
    fi
    echo init-build.sh
    echo "#!/bin/sh" > init-build.sh
    echo -n $BUILD_CMD >> init-build.sh
fi

if [ ! -f init-web.sh ]; then
    if [ -f Procfile ]; then
        WEB_CMD=$(cat Procfile | grep web | awk -F  ": " '{print $2}')
    else
        WEB_CMD=$KUBERO_BUILDPACK_DEFAULT_RUN_CMD
    fi
    echo init-web.sh
    echo "#!/bin/sh" > init-web.sh
    echo -n $WEB_CMD >> init-web.sh
fi

if [ ! -f init-worker.sh ]; then
    if [ -f Procfile ]; then
        WORKER_CMD=$(cat Procfile | grep worker | awk -F  ": " '{print $2}')
    else
        WORKER_CMD=$KUBERO_BUILDPACK_DEFAULT_RUN_CMD
    fi
    echo init-worker.sh
    echo "#!/bin/sh" > init-worker.sh
    echo -n $WORKER_CMD >> init-worker.sh
fi

chmod +x init-*.sh
