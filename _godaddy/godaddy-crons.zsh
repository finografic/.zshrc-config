crons-run() {

  echo "\n${Green}----------\n"

  MESSAGE='Running crons for: ES'
  echo "\n\e[32m ----------\e[37m $MESSAGE \e[32m----------\n"

  # KPI-ES
  php /var/www/kpi-es/kpi_exoticca/app/console exoticca:recollect:main --env=prod
  php /var/www/kpi-es/kpi_exoticca/app/console exoticca:recollect:google:main --env=prod
  php /var/www/kpi-es/kpi_exoticca/app/console exoticca:recollect:travels --env=prod
  php /var/www/kpi-es/kpi_exoticca/app/console exoticca:travels:new --env=prod
  php /var/www/kpi-es/kpi_exoticca/app/console exoticca:sales:new --env=prod
  php /var/www/kpi-es/kpi_exoticca/app/console exoticca:recollect:google:travel --env=prod # REQUIRES TIME-RANGE!!
  php /var/www/kpi-es/kpi_exoticca/app/console exoticca:feed:auto --env=prod
  php /var/www/kpi-es/kpi_exoticca/app/console exoticca:recollect:google:channel --env=prod
  php /var/www/kpi-es/kpi_exoticca/app/console exoticca:sales:channelComment --env=prod
  php /var/www/kpi-es/kpi_exoticca/app/console exoticca:recollect:google:campaign --env=prod
  php /var/www/kpi-es/kpi_exoticca/app/console exoticca:sales:assignation --env=prod
  php /var/www/kpi-es/kpi_exoticca/app/console exoticca:travels:minPrice --env=prod # ERROR force.exottica.de
  php /var/www/kpi-es/kpi_exoticca/app/console exoticca:feed:autopoi --env=prod
  php /var/www/kpi-es/kpi_exoticca/app/console exoticca:cohort:set --env=prod ### ERROR 586531a20be93b2b226117af not found
  php /var/www/kpi-es/kpi_exoticca/app/console exoticca:groups:fill --env=prod
  php /var/www/kpi-es/kpi_exoticca/app/console exoticca:sales:channelComment --env=prod
  php /var/www/kpi-es/kpi_exoticca/app/console exoticca:aircall:recollect normal --env=prod
  php /var/www/kpi-es/kpi_exoticca/app/console exoticca:admin:newMonth --env=prod
  php /var/www/kpi-es/kpi_exoticca/app/console wm:info:recollect:first --env=prod

  MESSAGE='Running crons for: UK'
  echo "\n\e[32m ----------\e[37m $MESSAGE \e[32m----------\n"

  # KPI-UK
  php /var/www/kpi-uk/kpi_exoticca/app/console exoticca:recollect:main --env=prod
  php /var/www/kpi-uk/kpi_exoticca/app/console exoticca:recollect:google:main --env=prod
  php /var/www/kpi-uk/kpi_exoticca/app/console exoticca:recollect:travels --env=prod
  php /var/www/kpi-uk/kpi_exoticca/app/console exoticca:sales:new --env=prod
  php /var/www/kpi-uk/kpi_exoticca/app/console exoticca:recollect:google:travel --env=prod
  php /var/www/kpi-uk/kpi_exoticca/app/console exoticca:feed:auto --env=prod
  php /var/www/kpi-uk/kpi_exoticca/app/console exoticca:recollect:google:channel --env=prod
  php /var/www/kpi-uk/kpi_exoticca/app/console exoticca:recollect:google:campaign --env=prod
  php /var/www/kpi-uk/kpi_exoticca/app/console exoticca:sales:assignation --env=prod
  php /var/www/kpi-uk/kpi_exoticca/app/console exoticca:travelzoo:premium --env=prod
  php /var/www/kpi-uk/kpi_exoticca/app/console exoticca:advice:atol --env=prod
  php /var/www/kpi-uk/kpi_exoticca/app/console exoticca:airline:data --env=prod
  php /var/www/kpi-uk/kpi_exoticca/app/console exoticca:travels:new --env=prod
  php /var/www/kpi-uk/kpi_exoticca/app/console exoticca:travels:minPrice --env=prod 
  php /var/www/kpi-uk/kpi_exoticca/app/console exoticca:feed:autopoi --env=prod
  php /var/www/kpi-uk/kpi_exoticca/app/console exoticca:cohort:set --env=prod
  php /var/www/kpi-uk/kpi_exoticca/app/console exoticca:groups:fill --env=prod
  php /var/www/kpi-uk/kpi_exoticca/app/console exoticca:sales:channelComment --env=prod
  php /var/www/kpi-uk/kpi_exoticca/app/console exoticca:aircall:recollect normal --env=prod
  php /var/www/kpi-uk/kpi_exoticca/app/console wm:info:recollect:first --env=prod
  php /var/www/kpi-uk/kpi_exoticca/app/console exoticca:admin:newMonth --env=prod

  MESSAGE='Running crons for: DE'
  echo "\n\e[32m ----------\e[37m $MESSAGE \e[32m----------\n"

  # KPI-DE
  php /var/www/kpi-de/kpi_exoticca/app/console exoticca:recollect:main --env=prod
  php /var/www/kpi-de/kpi_exoticca/app/console exoticca:recollect:google:main --env=prod
  php /var/www/kpi-de/kpi_exoticca/app/console exoticca:recollect:travels --env=prod
  php /var/www/kpi-de/kpi_exoticca/app/console exoticca:travels:new --env=prod
  php /var/www/kpi-de/kpi_exoticca/app/console exoticca:sales:new --env=prod
  php /var/www/kpi-de/kpi_exoticca/app/console exoticca:recollect:google:travel --env=prod
  php /var/www/kpi-de/kpi_exoticca/app/console exoticca:feed:auto --env=prod
  php /var/www/kpi-de/kpi_exoticca/app/console exoticca:recollect:google:channel --env=prod
  php /var/www/kpi-de/kpi_exoticca/app/console exoticca:sales:channelComment --env=prod
  php /var/www/kpi-de/kpi_exoticca/app/console exoticca:recollect:google:campaign --env=prod
  php /var/www/kpi-de/kpi_exoticca/app/console exoticca:sales:assignation --env=prod
  php /var/www/kpi-de/kpi_exoticca/app/console exoticca:travels:minPrice --env=prod
  php /var/www/kpi-de/kpi_exoticca/app/console exoticca:feed:autopoi --env=prod
  php /var/www/kpi-de/kpi_exoticca/app/console exoticca:cohort:set --env=prod
  php /var/www/kpi-de/kpi_exoticca/app/console exoticca:groups:fill --env=prod
  php /var/www/kpi-de/kpi_exoticca/app/console exoticca:sales:channelComment --env=prod
  php /var/www/kpi-de/kpi_exoticca/app/console exoticca:aircall:recollect normal --env=prod
  php /var/www/kpi-de/kpi_exoticca/app/console wm:info:recollect:first --env=prod
  php /var/www/kpi-de/kpi_exoticca/app/console exoticca:admin:newMonth --env=prod

  MESSAGE='Running crons for: FR'
  echo "\n\e[32m ----------\e[37m $MESSAGE \e[32m----------\n"

  # KPI-FR
  php /var/www/kpi-fr/kpi_exoticca/app/console exoticca:recollect:main --env=prod
  php /var/www/kpi-fr/kpi_exoticca/app/console exoticca:recollect:google:main --env=prod
  php /var/www/kpi-fr/kpi_exoticca/app/console exoticca:recollect:travels --env=prod
  php /var/www/kpi-fr/kpi_exoticca/app/console exoticca:sales:new --env=prod
  php /var/www/kpi-fr/kpi_exoticca/app/console exoticca:recollect:google:travel --env=prod
  php /var/www/kpi-fr/kpi_exoticca/app/console exoticca:feed:auto --env=prod
  php /var/www/kpi-fr/kpi_exoticca/app/console exoticca:recollect:google:channel --env=prod 
  php /var/www/kpi-fr/kpi_exoticca/app/console exoticca:recollect:google:campaign --env=prod
  php /var/www/kpi-fr/kpi_exoticca/app/console exoticca:sales:assignation --env=prod
  php /var/www/kpi-fr/kpi_exoticca/app/console exoticca:advice:atol --env=prod
  php /var/www/kpi-fr/kpi_exoticca/app/console exoticca:airline:data --env=prod
  php /var/www/kpi-fr/kpi_exoticca/app/console exoticca:travels:new --env=prod
  php /var/www/kpi-fr/kpi_exoticca/app/console exoticca:travels:minPrice --env=prod
  php /var/www/kpi-fr/kpi_exoticca/app/console exoticca:feed:autopoi --env=prod
  php /var/www/kpi-fr/kpi_exoticca/app/console exoticca:cohort:set --env=prod
  php /var/www/kpi-fr/kpi_exoticca/app/console exoticca:groups:fill --env=prod
  php /var/www/kpi-fr/kpi_exoticca/app/console exoticca:sales:channelComment --env=prod
  php /var/www/kpi-fr/kpi_exoticca/app/console exoticca:aircall:recollect normal --env=prod
  php /var/www/kpi-fr/kpi_exoticca/app/console wm:info:recollect:first --env=prod
  php /var/www/kpi-fr/kpi_exoticca/app/console exoticca:admin:newMonth --env=prod

  MESSAGE='Running crons for: US'
  echo "\n\e[32m ----------\e[37m $MESSAGE \e[32m----------\n"

  # KPI-US
  php /var/www/kpi-us/kpi_exoticca/app/console exoticca:airline:data --env=prod
  php /var/www/kpi-us/kpi_exoticca/app/console exoticca:recollect:main --env=prod
  php /var/www/kpi-us/kpi_exoticca/app/console exoticca:recollect:travels --env=prod
  php /var/www/kpi-us/kpi_exoticca/app/console exoticca:sales:new --env=prod
  php /var/www/kpi-us/kpi_exoticca/app/console exoticca:travels:new --env=prod
  php /var/www/kpi-us/kpi_exoticca/app/console exoticca:recollect:google:main --env=prod
  php /var/www/kpi-us/kpi_exoticca/app/console exoticca:recollect:google:campaign --env=prod
  php /var/www/kpi-us/kpi_exoticca/app/console exoticca:recollect:google:travel --env=prod
  php /var/www/kpi-us/kpi_exoticca/app/console exoticca:admin:newMonth --env=prod
  php /var/www/kpi-us/kpi_exoticca/app/console exoticca:travels:minPrice --env=prod
  php /var/www/kpi-us/kpi_exoticca/app/console exoticca:sales:assignation --env=prod
  php /var/www/kpi-us/kpi_exoticca/app/console exoticca:feed:auto --env=prod
  php /var/www/kpi-us/kpi_exoticca/app/console exoticca:feed:autopoi --env=prod
  php /var/www/kpi-us/kpi_exoticca/app/console exoticca:cohort:set --env=prod
  php /var/www/kpi-us/kpi_exoticca/app/console exoticca:groups:fill --env=prod
  php /var/www/kpi-us/kpi_exoticca/app/console exoticca:sales:channelComment --env=prod
  php /var/www/kpi-us/kpi_exoticca/app/console exoticca:aircall:recollect normal --env=prod

}
