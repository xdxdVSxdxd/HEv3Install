#!/bin/bash
CMD=$1
ID=$2
if [ "$#" -ne 2 ];
	then
		echo "syntax: ./install_hev3 CMD NAME"
	else
		if [ "$CMD" = "install" ]; then
			echo "installing HE instance [$ID]"
		
			ret=false
			getent passwd $ID >/dev/null 2>&1 && ret=true

			if $ret; then
    				echo "USER already exists: use a different name fo ID"
			else
    				echo "creating user"
				useradd $ID
				echo "password for user?"
				passwd $ID
				chsh -s /bin/bash $ID
				mkdir "/home/$ID"
				mkdir "/home/$ID/public_html"
				mkdir "/home/$ID/public_html/HEv3"
				chown $ID /home/$ID
				chown $ID /home/$ID/public_html
				chown $ID /home/$ID/public_html/HEv3
				chgrp -R $ID /home/$ID
				unzip HEv3.zip -d /home/$ID/public_html/HEv3
				chown -R $ID /home/$ID/public_html/HEv3
				chgrp -R $ID /home/$ID/public_html/HEv3
				chown -R www-data /home/$ID/public_html/HEv3/logs
				chown -R www-data /home/$ID/public_html/HEv3/tmp
				chgrp -R www-data /home/$ID/public_html/HEv3/logs
				chgrp -R www-data /home/$ID/public_html/HEv3/tmp
				chmod -R 755 /home/$ID/public_html/HEv3/tmp
				echo "Database Name?"
				read dbname
				echo "Database User?"
				read dbuser
				echo "Database Password?"
				read dbpassword
				
				sed -i -e "s/'host' => ''/'host' => 'localhost'/g" /home/$ID/public_html/HEv3/config/app_local.php
				sed -i -e "s/'username' => ''/'username' => '$dbuser'/g" /home/$ID/public_html/HEv3/config/app_local.php
				sed -i -e "s/'password' => ''/'password' => '$dbpassword'/g" /home/$ID/public_html/HEv3/config/app_local.php
				sed -i -e "s/'database' => ''/'database' => '$dbname'/g" /home/$ID/public_html/HEv3/config/app_local.php

				sed -i -e "s/'host' => ''/'host' => 'localhost'/g" /home/$ID/public_html/HEv3/config/app.default.php
				sed -i -e "s/'username' => ''/'username' => '$dbuser'/g" /home/$ID/public_html/HEv3/config/app.default.php
				sed -i -e "s/'password' => ''/'password' => '$dbpassword'/g" /home/$ID/public_html/HEv3/config/app.default.php
				sed -i -e "s/'database' => ''/'database' => '$dbname'/g" /home/$ID/public_html/HEv3/config/app.default.php

				sed -i -e "s/'host' => ''/'host' => 'localhost'/g" /home/$ID/public_html/HEv3/config/app.php
				sed -i -e "s/'username' => ''/'username' => '$dbuser'/g" /home/$ID/public_html/HEv3/config/app.php
				sed -i -e "s/'password' => ''/'password' => '$dbpassword'/g" /home/$ID/public_html/HEv3/config/app.php
				sed -i -e "s/'database' => ''/'database' => '$dbname'/g" /home/$ID/public_html/HEv3/config/app.php

				mysql $dbname -u $dbuser -p$dbpassword < /home/$ID/public_html/HEv3/DatabaseSchemes/Schema.sql
				
				su - $ID -c "composer require jublonet/codebird-php"
				su - $ID -c "composer require raiym/instagram-php-scraper"
				
				rm /home/$ID/public_html/HEv3/.htaccess
				cp install_HEv3_files/root_htaccess /home/$ID/public_html/HEv3/.htaccess
				chgrp www-data /home/$ID/public_html/HEv3/.htaccess
				chown www-data /home/$ID/public_html/HEv3/.htaccess

				rm /home/$ID/public_html/HEv3/webroot/.htaccess
                                cp install_HEv3_files/webroot_htaccess /home/$ID/public_html/HEv3/webroot/.htaccess
				chgrp www-data /home/$ID/public_html/HEv3/webroot/.htaccess
				chown www-data /home/$ID/public_html/HEv3/webroot/.htaccess

				sed -i -e "s/\[ID\]/$ID/g" /home/$ID/public_html/HEv3/webroot/.htaccess
				sed -i -e "s/\[ID\]/$ID/g" /home/$ID/public_html/HEv3/.htaccess

				echo "--------------------------------"
				echo "READY!"
				echo "--------------------------------"
				echo "See this link below to see next steps:"
				echo "https://github.com/xdxdVSxdxd/HumanEcosystemsv3/wiki/Install-Config"
				echo "-------------------------------"
			fi
		elif [ "$CMD" = "remove" ]; then
			userdel $ID
			rm -R /home/$ID
		else
			echo "Wrong CMD! Available: install"
		fi
fi
