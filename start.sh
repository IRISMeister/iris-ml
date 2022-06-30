#!/bin/bash -e

docker-compose up -d
docker-compose exec -T iris bash -c "\$ISC_PACKAGE_INSTALLDIR/dev/Cloud/ICM/waitISC.sh '' 60"
docker-compose exec -T iris iris session iris -U USER < import.cos
