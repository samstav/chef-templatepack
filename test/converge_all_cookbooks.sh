DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for i in tmp/*
do
  #DIR=$(echo ${i} | awk -F'/' '{print $2}')
  #UUID=$(knife rackspace server list -A ${RACKSPACE_USERNAME} -K ${RACKSPACE_API_KEY} --rackspace-region DFW | fgrep ${DIR} | awk '{print $1}')
  #knife racksapce server delete -y ${UUID} --purge
  cd "${DIR}/../${i}"
  kitchen test
  if [ "$?" -ne "0" ]; then
    echo "Test for ${i} failed"
    exit 1
  fi
done

cd $DIR
