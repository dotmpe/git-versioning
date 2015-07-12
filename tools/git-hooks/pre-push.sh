# Id: git-versioning/0.0.27 tools/git-hooks/pre-push.sh
while read LOCAL_REF LOCAL_SHA1 REMOTE_REF REMOTE_SHA1
do
  make git-pre-push \
    LOCAL_REF=$LOCAL_REF \
    LOCAL_SHA1=$LOCAL_SHA1 \
    REMOTE_REF=$REMOTE_REF \
    REMOTE_SHA1=$REMOTE_SHA1
done
