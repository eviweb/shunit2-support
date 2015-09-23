#! /bin/bash
replaceHeader()
{
    local file="$1"
    local actual='\#! /bin/bash'
    local replacement="$(cat ${TPLDIR}/header.tpl)"
    local content="$(cat ${file})"

    content="${content/$actual/$replacement}"

    echo "$content" > ${file}
}

fixDirVariable()
{
    local file="$1"

    sed -i 's/DIR=$(dirname $(readlink -f "$0"))/DIR="$(mydir)"/' ${file}
}

update()
{
    local file="$1"

    replaceHeader "${file}"
    fixDirVariable "${file}"
}